import SwiftUI
import WalletService
import WalletAvatar
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents
import ExplorerService
import Store

public class WalletDetailViewModel {

    @Binding var navigationPath: NavigationPath
    let wallet: Wallet
    let walletService: WalletService
    let explorerService: any ExplorerLinkFetchable

    public init(
        navigationPath: Binding<NavigationPath>,
        wallet: Wallet,
        walletService: WalletService,
        explorerService: any ExplorerLinkFetchable = ExplorerService.standard
    ) {
        _navigationPath = navigationPath
        self.wallet = wallet
        self.walletService = walletService
        self.explorerService = explorerService
    }

    var name: String {
        wallet.name
    }
    
    var title: String {
        return Localized.Common.wallet
    }
    
    var address: WalletDetailAddress? {
        switch wallet.type {
        case .multicoin:
            return .none
        case .single, .view, .privateKey:
            guard let account = wallet.accounts.first else { return .none }
            return WalletDetailAddress.account(
                SimpleAccount(
                    name: .none,
                    chain: account.chain,
                    address: account.address,
                    assetImage: .none
                )
            )
        }
    }
    
    var walletRequest: WalletRequest {
        WalletRequest(walletId: wallet.id)
    }
    
    func avatarAssetImage(for wallet: Wallet) -> AssetImage {
        let avatar = WalletViewModel(wallet: wallet).avatarImage
        return AssetImage(
            type: avatar.type,
            imageURL: avatar.imageURL,
            placeholder: avatar.placeholder,
            chainPlaceholder: Images.Wallets.editFilled
        )
    }
}

// MARK: - Business Logic

extension WalletDetailViewModel {
    func rename(name: String) throws {
        try walletService.rename(walletId: wallet.walletId, newName: name)
    }
    
    func getMnemonicWords() throws -> [String] {
        try walletService.getMnemonic(wallet: wallet)
    }
    
    func getPrivateKey() throws -> String {
        let chain = wallet.accounts[0].chain
        return try walletService.getPrivateKey(
            wallet: wallet,
            chain: chain,
            encoding: chain.defaultKeyEncodingType
        )
    }

    func delete() throws {
        try walletService.delete(wallet)
    }

    func onSelectImage() {
        navigationPath.append(Scenes.WalletSelectImage(wallet: wallet))
    }
}
