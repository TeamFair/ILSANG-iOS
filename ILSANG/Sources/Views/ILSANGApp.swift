//
//  ILSANGApp.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/19/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        NotificationCenter.default.removeObserver(self, name: .sessionExpired, object: nil)
        NotificationCenter.default.addObserver(forName: .sessionExpired, object: nil, queue: .main) { _ in
            Task { @MainActor in
                await UserService.shared.logout()
            }
        }
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct ILSANGApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dependencies = AppDependencies()
    @StateObject private var sharedState = SharedState()
    @AppStorage("isLogin") var isLogin = Bool()
    
    @State private var isTutorialVisible = Bool()
    @State private var isSplashScreenVisible = true
    @State private var showSheet = false
    
    // 강제 업데이트 관련
    @State private var needUpdate = false
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        setAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                let size = proxy.size
                let layout = LayoutInfo.forSize(size)

                ZStack {
                    if isSplashScreenVisible {
                        SplashScreenView()
                    } else if !isLogin {
                        LoginView(vm: LoginViewModel())
                    } else {
                        MainTabView()
                            .environmentObject(dependencies)
                            .environmentObject(sharedState)
                            .fullScreenCover(isPresented: $isTutorialVisible) {
                                TutorialView()
                            }
                    }
                }
                .ignoresSafeArea()
                .environment(\.layout, layout) // 레이아웃 환경 주입
            }
#if !RELEASE
            .overlay(alignment: .topLeading) {
                Button { showSheet = true } label: {
                    Text("로그인 정보")
                }
            }
            .sheet(isPresented: $showSheet, content: {
                loginInfoView
            })
#endif

            .alert("업데이트 알림", isPresented: $needUpdate, actions: {
                Button("업데이트") { AppVersionManager.shared.openAppStore() }
            }, message: {
                Text("일상이 새롭게 업데이트되었습니다!\n변화된 일상을 만나보세요.")
            })
            .onChange(of: scenePhase, { _, newValue in
                if newValue == .active {
                    Task { await checkAndUpdateVersionIfNeeded() }
                }
            })
            .onChange(of: isLogin, { _, newValue in // 로그인 후 튜토리얼 UI 표시
                if newValue {
                    isTutorialVisible = true
                    Task { await dependencies.seasonManager.fetchSeasons() }
                }
            })
            .task {
                await runAppStartup()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                /// 백그라운드 진입 시 디스크 캐시 정리
                ImageCacheService.shared.cleanupDiskCache()
            }
        }
    }
    
#if !RELEASE
    private var loginInfoView: some View {
        ScrollView {
            VStack(spacing: 20) {
                showItems("Provider", UserService.shared.currentUser?.email ?? "")
                showItems("Provider", UserService.shared.authChannel)
                showItems("AuthToken", UserService.shared.accessToken)
                showItems("RefreshToken", UserService.shared.refreshToken)
                Button {
                    UserService.shared.accessToken = ""
                } label: {
                    Text("REMOVE AuthToken")
                }
            }
            .padding(20)
        }
    }
    
    private func showItems(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(title)
                .styledFont(.heading2)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .styledFont(.body)
                .frame(maxWidth: .infinity)
            Button {
                copyToClipboard(text: value)
            } label: {
                Image(systemName: "doc.on.clipboard.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.blue)
            }
            .frame(20)
        }
        .foregroundStyle(.black)
    }
#endif
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        let feedbackGenerator = UISelectionFeedbackGenerator()

        feedbackGenerator.prepare()
        feedbackGenerator.selectionChanged()
    }
    
    @MainActor
    private func runAppStartup() async {
        // 1. 스플래시 화면 표시
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초 대기
        
        // 2. 로그인 상태 확인 -> API 호출 시 401 에러나면 로그인 화면으로 이동 (isLogin = false)
        if isLogin {
            // try await UserService.shared.login()
            await UserService.shared.fetchUserInfo()
        }
        
        // 3. 업데이트 확인
        await checkAndUpdateVersionIfNeeded()
        
        // 4. 스플래시 화면 종료
        isSplashScreenVisible = false
    }
    
    private func checkAndUpdateVersionIfNeeded() async {
        do {
            needUpdate = try await AppVersionManager.shared.isUpdateAvailable()
        } catch {
            Log("버전 확인 중 오류 발생: \(error)")
        }
    }
    
    func setAppearance() {
        // 탭바
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(.white)
        appearance.shadowColor = UIColor(.grayDD)
        appearance.stackedItemPositioning = .centered
        
        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // 틴트 컬러 적용
        UIView.appearance().tintColor = UIColor(named: "AccentColor") // 파란색으로 버튼이 보여지는 문제 방지 (Alert에서 문제 발생)
    }
}

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            Image(.logoWithAlpha) /// 런치스크린에서 사용한 이미지
                .resizable()
                .scaledToFit()
                .frame(width: 152)
                .ignoresSafeArea()
        }
    }
}

public func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcName: String = #function) {
#if DEBUG
    if let obj = object {
        print("\(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(obj)") // \(funcName) : \(obj)")
    } else {
        print("\(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : nil")
    }
#endif
}
