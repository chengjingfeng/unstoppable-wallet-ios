import RxSwift
import RealmSwift

typealias CoinCode = String

protocol IRandomManager {
    func getRandomIndexes(count: Int) -> [Int]
}

protocol IRealmFactory {
    var realm: Realm { get }
}

protocol ILocalStorage: class {
    var isBackedUp: Bool { get set }
    var baseCurrencyCode: String? { get set }
    var lightMode: Bool { get set }
    var iUnderstand: Bool { get set }
    var isBiometricOn: Bool { get set }
    var currentLanguage: String? { get set }
    var lastExitDate: Double { get set }
    var didLaunchOnce: Bool { get }
    func clear()
}

protocol ISecureStorage: class {
    var authData: AuthData? { get }
    func set(authData: AuthData?) throws
    var pin: String? { get }
    func set(pin: String?) throws
    var unlockAttempts: Int? { get }
    func set(unlockAttempts: Int?) throws
    var lockoutTimestamp: TimeInterval? { get }
    func set(lockoutTimestamp: TimeInterval?) throws
    func clear()
}

protocol ILanguageManager {
    var currentLanguage: String { get set }
    var displayNameForCurrentLanguage: String { get }

    func localize(string: String) -> String
    func localize(string: String, arguments: [CVarArg]) -> String
}

protocol ILocalizationManager {
    var preferredLanguage: String? { get }
    var availableLanguages: [String] { get }
    func displayName(forLanguage language: String, inLanguage: String) -> String

    func setLocale(forLanguage language: String)
    func localize(string: String, language: String) -> String?
    func format(localizedString: String, arguments: [CVarArg]) -> String
}

protocol IWalletManager: class {
    var wallets: [Wallet] { get }
    var walletsUpdatedSignal: Signal { get }
    func initWallets()
    func clearWallets()
}

protocol IAdapterFactory {
    func adapter(forCoinType type: CoinType, authData: AuthData) -> IAdapter?
}

protocol IWalletFactory {
    func wallet(forCoin coin: Coin, authData: AuthData) -> Wallet?
}

protocol ICoinManager {
    var coins: [Coin] { get }
}

protocol ITransactionManager: class {
    func clear()
}

enum AdapterState {
    case synced
    case syncing(progressSubject: BehaviorSubject<Double>?)
    case notSynced
}

enum FeeError: Error {
    case insufficientAmount(fee: Double)
}

protocol IAdapter: class {
    var balance: Double { get }
    var balanceUpdatedSignal: Signal { get }

    var state: AdapterState { get }
    var stateUpdatedSignal: Signal { get }

    var confirmationsThreshold: Int { get }
    var lastBlockHeight: Int? { get }
    var lastBlockHeightSubject: PublishSubject<Int> { get }

    var transactionRecordsSubject: PublishSubject<[TransactionRecord]> { get }

    var debugInfo: String { get }

    var refreshable: Bool { get }

    func start()
    func refresh()
    func clear()

    func send(to address: String, value: Double, completion: ((Error?) -> ())?)

    func fee(for value: Double, address: String?, senderPay: Bool) throws -> Double
    func validate(address: String) throws
    func parse(paymentAddress: String) -> PaymentRequestAddress

    var receiveAddress: String { get }
}

protocol IWordsManager {
    var isBackedUp: Bool { get set }
    var backedUpSignal: Signal { get }
    func generateWords() throws -> [String]
    func validate(words: [String]) throws
}

protocol IAuthManager {
    var authData: AuthData? { get }
    var isLoggedIn: Bool { get }
    func login(withWords words: [String]) throws
    func logout() throws
}

protocol ILockManager {
    var isLocked: Bool { get }
    func lock()
    func didEnterBackground()
    func willEnterForeground()
}

protocol IBlurManager {
    func willResignActive()
    func didBecomeActive()
}

protocol IPinManager: class {
    var isPinSet: Bool { get }
    func store(pin: String?) throws
    func validate(pin: String) -> Bool
    func clearPin() throws
}

protocol ILockRouter {
    func showUnlock(delegate: IUnlockDelegate?)
}

protocol IBiometricManager {
    func validate(reason: String)
}

protocol BiometricManagerDelegate: class {
    func didValidate()
    func didFailToValidate()
}

protocol IRateManager {
    func refreshRates(coinCodes: [CoinCode], currencyCode: String)
}

protocol IRateSyncerDelegate: class {
    func didSync(coinCode: String, currencyCode: String, latestRate: LatestRate)
}

protocol ISystemInfoManager {
    var appVersion: String { get }
    var biometryType: BiometryType { get }
}

protocol IAppConfigProvider {
    var reachabilityHost: String { get }
    var ratesApiUrl: String { get }
    var testMode: Bool { get }
    var currencies: [Currency] { get }

    var defaultWords: [String] { get }
    var disablePinLock: Bool { get }
}

protocol IFullTransactionInfoProvider {
    var providerName: String { get }
    func url(for hash: String) -> String

    func retrieveTransactionInfo(transactionHash: String) -> Observable<FullTransactionRecord?>
}

protocol IFullTransactionInfoAdapter {
    func convert(json: [String: Any]) -> FullTransactionRecord?
}

protocol IRateNetworkManager {
    func getLatestRate(coinCode: String, currencyCode: String) -> Observable<LatestRate>
    func getRate(coinCode: String, currencyCode: String, date: Date) -> Observable<Double>
}

protocol IRateStorage {
    func rateObservable(forCoinCode coinCode: CoinCode, currencyCode: String) -> Observable<Rate>
    func save(rate: Rate)
    func clear()
}

protocol IJSONApiManager {
    func getJSON(url: String, parameters: [String: Any]?) -> Observable<[String: Any]>
}

protocol IFullTransactionHelper {
    func map(json: [String: Any]) -> FullTransactionRecord?
}

protocol ITransactionRecordStorage {
    func record(forHash hash: String) -> TransactionRecord?
    var nonFilledRecords: [TransactionRecord] { get }
    func set(rate: Double, transactionHash: String)
    func clearRates()

    func update(records: [TransactionRecord])
    func clearRecords()
}

protocol ICurrencyManager {
    var currencies: [Currency] { get }
    var baseCurrency: Currency { get }
    var baseCurrencyUpdatedSignal: Signal { get }

    func setBaseCurrency(code: String)
}

protocol IReachabilityManager {
    var isReachable: Bool { get }
    var reachabilitySignal: Signal { get }
}

protocol IPeriodicTimer {
    var delegate: IPeriodicTimerDelegate? { get set }
    func schedule()
}

protocol IOneTimeTimer {
    var delegate: IPeriodicTimerDelegate? { get set }
    func schedule(date: Date)
}

protocol IPeriodicTimerDelegate: class {
    func onFire()
}

protocol ITransactionRateSyncer {
    func sync(currencyCode: String)
    func cancelCurrentSync()
}

protocol IPasteboardManager {
    var value: String? { get }
    func set(value: String)
}

protocol IUrlManager {
    func open(url: String, from controller: UIViewController?)
}

protocol ITransactionViewItemFactory {
    func item(fromRecord record: TransactionRecord) -> TransactionViewItem
}

protocol IFullTransactionInfoProviderFactory {
    func provider(`for` coinCode: String) -> IFullTransactionInfoProvider
}

protocol ISettingsProviderMap {
    func bitcoin(for name: String) -> IBitcoinForksProvider
    func bitcoinCash(for name: String) -> IBitcoinForksProvider
    func ethereum(for name: String) -> IEthereumForksProvider
}

protocol IProvider {
    var name: String { get }
    func url(for hash: String) -> String
    func apiUrl(for hash: String) -> String
}

protocol ILockoutManager {
    var currentState: LockoutState { get }
    func didFailUnlock()
    func dropFailedAttempts()
}

protocol ILockoutUntilDateFactory {
    func lockoutUntilDate(failedAttempts: Int, lockoutTimestamp: TimeInterval, uptime: TimeInterval) -> Date
}

protocol ICurrentDateProvider {
    var currentDate: Date { get }
}

protocol IUptimeProvider {
    var uptime: TimeInterval { get }
}

protocol ILockoutTimeFrameFactory {
    func lockoutTimeFrame(failedAttempts: Int, lockoutTimestamp: TimeInterval, uptime: TimeInterval) -> TimeInterval
}
