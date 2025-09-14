//
//  AppDependencies.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/1/25.
//

import Combine

@MainActor
class AppDependencies: ObservableObject {
    // MARK: - Networks
    let userNetwork: UserNetwork
    let emojiNetwork: EmojiNetwork
    let missionHistoryNetwork: MissionHistoryNetwork
    let areaNetwork: AreaNetwork
    let seasonNetwork: SeasonNetwork
    let rankNetwork: RankNetwork
    let imageNetwork: ImageNetwork
    let challengeNetwork: ChallengeNetwork
    let questNetwork: QuestNetwork
    let titleNetwork: TitleNetworkInterface
    let favoriteNetwork: FavoriteNetwork
    let bannerNetwork: BannerNetwork
    let couponNetwork: CouponNetwork
    
    // MARK: - Repositories
    let userRepository: UserRepositoryInterface
    let missionHistoryRepository: MissionHistoryRepository
    let areaRepository: AreaRepositoryInterface
    let rankRepository: RankRepositoryInterface
    let questRepository: QuestRepositoryInterface
    let bannerRepository: BannerRepositoryInterface
    let couponRepository: CouponRepositoryInterface
    let titleRepository: TitleRepositoryInterface
    
    // MARK: - Services
    let illsangZoneManager: IllsangZoneManager
    let areaNameService: AreaNameProvider
    let seasonManager: SeasonManager
    let imageChallengeSubmitService: ImageChallengeSubmitService
    let favoriteService: FavoriteService
    let honorAcquisitionManager: HonorAcquisitionManager
    let questSubmissionNotifier: QuestSubmissionNotifier

    init() {
        // Networks
        self.userNetwork = UserNetwork()
        self.emojiNetwork = EmojiNetwork()
        self.missionHistoryNetwork = MissionHistoryNetwork()
        self.areaNetwork = AreaNetwork()
        self.seasonNetwork = SeasonNetwork()
        self.rankNetwork = RankNetwork()
        self.imageNetwork = ImageNetwork()
        self.challengeNetwork = ChallengeNetwork()
        self.questNetwork = QuestNetwork()
        self.titleNetwork = TitleNetwork()
        self.favoriteNetwork = FavoriteNetwork()
        self.bannerNetwork = BannerNetwork()
        self.couponNetwork = CouponNetwork()
        
        // Repositories
        self.userRepository = UserRepository(network: userNetwork)
        self.missionHistoryRepository = MissionHistoryRepository(network: missionHistoryNetwork)
        self.areaRepository = AreaRepository(network: areaNetwork)
        self.rankRepository = RankRepository(network: rankNetwork)
        self.questRepository = QuestRepository(network: questNetwork)
        self.bannerRepository = BannerRepository(network: bannerNetwork)
        self.couponRepository = CouponRepository(network: couponNetwork)
        self.titleRepository = TitleRepository(network: titleNetwork)
        
        // Services
        self.areaNameService = AreaNameService(areaRepository: areaRepository)
        self.seasonManager = SeasonManager(seasonNetwork: seasonNetwork)
        self.illsangZoneManager = IllsangZoneManager(areaNameService: areaNameService, seasonManager: seasonManager)
        self.imageChallengeSubmitService = ImageChallengeSubmitService(imageNetwork: imageNetwork, challengeNetwork: challengeNetwork)
        self.favoriteService = FavoriteService(favoriteNetwork: favoriteNetwork)
        self.honorAcquisitionManager = HonorAcquisitionManager(titleRepository: titleRepository)
        self.questSubmissionNotifier = QuestSubmissionNotifier()
    }
}
