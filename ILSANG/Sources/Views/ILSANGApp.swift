//
//  ILSANGApp.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/19/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if RELEASE
         FirebaseApp.configure()
#endif
        return true
    }
}

@main
struct ILSANGApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @AppStorage("isLogin") var isLogin = Bool()
    
    @State private var isTutorialVisible = Bool()
    @State private var isSplashScreenVisible = true
    
    // 강제 업데이트 관련
    @State private var needUpdate = false
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        setAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashScreenVisible {
                    SplashScreenView()
                } else if !isLogin {
                    LoginView(vm: LoginViewModel())
                } else {
                    MainTabView()
                        .fullScreenCover(isPresented: $isTutorialVisible) {
                            TutorialView()
                        }
                }
            }
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
    
    @MainActor
    private func runAppStartup() async {
        // 1. 스플래시 화면 표시
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초 대기
        
        // 2. 로그인 상태 확인
        if isLogin {
            let _ = await UserService.shared.login()
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
            VStack {
                Image(.logo) /// 런치스크린에서 사용한 이미지
                    .resizable()
                    .scaledToFit()
                    .frame(width: 172, height: 172)
                    .offset(y: -8)
                    .ignoresSafeArea()
            }
        }
    }
}

public func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcName: String = #function) {
#if DEBUG
    if let obj = object {
        print("\(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : \(obj)")
    } else {
        print("\(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : nil")
    }
#endif
}
