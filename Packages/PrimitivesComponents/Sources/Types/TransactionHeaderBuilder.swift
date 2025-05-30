// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct TransactionHeaderTypeBuilder {
    public static func build(
        infoModel: TransactionInfoViewModel,
        type: TransactionType,
        swapMetadata: SwapMetadata?
    ) -> TransactionHeaderType {
        let inputType: TransactionHeaderInputType = {
            switch type {
            case .transfer,
                    .stakeDelegate,
                    .stakeUndelegate,
                    .stakeRedelegate,
                    .stakeRewards,
                    .stakeWithdraw,
                    .transferNFT,
                    .smartContractCall:
                return .amount(showFiatSubtitle: true)
            case .swap:
                guard let swapMetadata else {
                    fatalError("swapMetadata is missed")
                }
                let model = SwapMetadataViewModel(metadata: swapMetadata)
                guard let input = model.headerInput else {
                    fatalError("fromAsset & toAsset missed")
                }
                return .swap(input)
            case .assetActivation:
                return .symbol
            case .tokenApproval:
                if infoModel.isZero {
                    return .amount(showFiatSubtitle: false)
                } else {
                    return .symbol
                }
            }
        }()
        return infoModel.headerType(input: inputType)
    }

    public static func build(
        infoModel: TransactionInfoViewModel,
        dataType: TransferDataType,
        metadata: TransferDataMetadata?
    ) -> TransactionHeaderType {
        let inputType: TransactionHeaderInputType = {
            switch dataType {
            case .transfer,
                    .generic,
                    .stake,
                    .tokenApprove:
                return .amount(
                    showFiatSubtitle: true
                )
            case .transferNft(let asset):
                return .nft(asset)
            case .account(_, let type):
                switch type {
                case .activate:
                    return .amount(
                        showFiatSubtitle: false
                    )
                }
            case .swap(let fromAsset, let toAsset, let quote, _):
                let assetPrices = (metadata?.assetPrices ?? [:]).map { (assetId, price) in
                    price.mapToAssetPrice(assetId: assetId)
                }
                
                let model = SwapMetadataViewModel(
                    metadata: SwapMetadata(
                        assets: [fromAsset, toAsset],
                        assetPrices: assetPrices,
                        transactionMetadata: TransactionSwapMetadata(
                            fromAsset: fromAsset.id,
                            fromValue: quote.fromValue,
                            toAsset: toAsset.id,
                            toValue: quote.toValue,
                            provider: quote.data.provider.protocolId
                        )
                    )
                )

                guard let input = model.headerInput else {
                    fatalError("fromAsset & toAsset missed")
                }
                return .swap(input)
            }
        }()
        return infoModel.headerType(input: inputType)
    }
}
