import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import ViewResolver from 0x631e88ae7f1d7c20

access(all) contract ItemManager: NonFungibleToken {

    access(all) event Minted(
    id: UInt64,
    uuid: UInt64,
    minter: Address,

    name: String,
    description: String,
    itemType: String,
    rarity: String,
    stackable: Bool,

    weapon: {String: UInt64}?,
    armour: {String: UInt64}?,
    consumable: {String: UInt64}?,
    accessory: {String: UInt64}?,
    imgURL: String?,
)

    // ===== Enums =====
    access(all) enum ItemType: UInt8 
    {
        access(all) case Weapon
        access(all) case Armour
        access(all) case Consumable
        access(all) case Accessory
        access(all) case Default
    }
    access(all) fun itemTypeToString(_ itemType: ItemType): String {
        switch itemType 
        {
            case ItemType.Weapon: return "Weapon"
            case ItemType.Armour: return "Armour"
            case ItemType.Consumable: return "Consumable"
            case ItemType.Accessory: return "Accessory"
            case ItemType.Default: return "Default"
        }
        return "Unknown"
    }
    access(all) enum Rarity: UInt8 {
        access(all) case Common
        access(all) case Uncommon
        access(all) case Rare
        access(all) case Epic
        access(all) case Legendary
    }
    access(all) fun rarityToString(_ rarity: Rarity): String {
        switch rarity 
        {
            case Rarity.Common: return "Common"
            case Rarity.Uncommon: return "Uncommon"
            case Rarity.Rare: return "Rare"
            case Rarity.Epic: return "Epic"
            case Rarity.Legendary: return "Legendary"
        }
        return "Unknown"
    }

    access(all) enum ArmourSlot: UInt64 {
        access(all) case Helmet
        access(all) case Chest
        access(all) case Leggings
        access(all) case Boots
    }

    access(all) struct WeaponData {
        access(all) let damage: UInt64
        access(all) let attackSpeed: UInt64
        access(all) let criticalRate: UInt64
        access(all) let criticalDamage: UInt64

        init(damage: UInt64, attackSpeed: UInt64, criticalRate: UInt64, criticalDamage: UInt64) {
            self.damage = damage
            self.attackSpeed = attackSpeed
            self.criticalRate = criticalRate
            self.criticalDamage = criticalDamage
        }
    }

    access(all) struct ArmourData {
        access(all) let slot: ArmourSlot
        access(all) let maxHealth: UInt64
        access(all) let defense: UInt64
        access(all) let healthRegen: UInt64
        access(all) let resistances: UInt64

        init(slot: ArmourSlot, maxHealth: UInt64, defense: UInt64, healthRegen: UInt64, resistances: UInt64) {
            self.slot = slot
            self.maxHealth = maxHealth
            self.defense = defense
            self.healthRegen = healthRegen
            self.resistances = resistances
        }
    }

    access(all) struct ConsumableData {
        access(all) let healthAffected: UInt64
        access(all) let manaAffected: UInt64
        access(all) let energyAffected: UInt64
        access(all) let cooldown: UInt64
        access(all) let duration: UInt64

        init(healthAffected: UInt64, manaAffected: UInt64, energyAffected: UInt64, cooldown: UInt64, duration: UInt64) {
            self.healthAffected = healthAffected
            self.manaAffected = manaAffected
            self.energyAffected = energyAffected
            self.cooldown = cooldown
            self.duration = duration
        }
    }

    access(all) struct AccessoryData {
        access(all) let bonusEnergy: UInt64
        access(all) let bonusMana: UInt64
        access(all) let bonusManaRegen: UInt64
        access(all) let bonusEnergyRegen: UInt64

        init(bonusEnergy: UInt64, bonusMana: UInt64, bonusManaRegen: UInt64, bonusEnergyRegen: UInt64) {
            self.bonusEnergy = bonusEnergy
            self.bonusMana = bonusMana
            self.bonusManaRegen = bonusManaRegen
            self.bonusEnergyRegen = bonusEnergyRegen
        }
    }
    
    access(all) let CollectionStoragePath: StoragePath
    access(all) let CollectionPublicPath: PublicPath

    access(all) let MinterStoragePath: StoragePath


    /// Gets a list of views for all the NFTs defined by this contract
    access(all) view fun getContractViews(resourceType: Type?): [Type] 
    {
        return [
            Type<MetadataViews.NFTCollectionData>(),
            Type<MetadataViews.NFTCollectionDisplay>()
        ]
    }
    access(all) fun resolveContractView(resourceType: Type?, viewType: Type): AnyStruct? 
    {
        switch viewType {
            case Type<MetadataViews.NFTCollectionData>():
                let collectionData = MetadataViews.NFTCollectionData(
                    storagePath: self.CollectionStoragePath,
                    publicPath: self.CollectionPublicPath,
                    publicCollection: Type<&ItemManager.Collection>(),
                    publicLinkedType: Type<&ItemManager.Collection>(),
                    createEmptyCollectionFunction: (fun(): @{NonFungibleToken.Collection} {
                        return <-ItemManager.createEmptyCollection(nftType: Type<@ItemManager.NFT>())
                    })
                )
                return collectionData
            case Type<MetadataViews.NFTCollectionDisplay>():
                let media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: "Add your own SVG+XML link here"
                    ),
                    mediaType: "image/svg+xml"
                )
                return MetadataViews.NFTCollectionDisplay(
                    name: "The ItemManager Example Collection",
                    description: "This collection is used as an example to help you develop your next Flow NFT.",
                    externalURL: MetadataViews.ExternalURL("Add your own link here"),
                    squareImage: media,
                    bannerImage: media,
                    socials: {
                        "twitter": MetadataViews.ExternalURL("Add a link to your project's twitter")
                    }
                )
        }
        return nil
    }

    // access(all) resource NFTMinter 
    // {
    //     access(all) fun createNFT(): @NFT {
    //         return <-create NFT(            
    //             id: receiver,
    //             name: "Sword of Testing",
    //             description: "A test sword",
    //             itemType: ItemManager.ItemType.Weapon,
    //             rarity: ItemManager.Rarity.Common,
    //             stackable: false,
    //             weapon: ItemManager.WeaponData(
    //                 damage: 10,
    //                 attackSpeed: 1,
    //                 criticalRate: 5,
    //                 criticalDamage: 50
    //             ),
    //             armour: nil,
    //             consumable: nil,
    //             accessory: nil
    //         )
    //     }
    //     init() {}
    // }
    
    // ===== Resource: NFT Item =====
    access(all) resource NFT: NonFungibleToken.NFT, ViewResolver.Resolver {
        access(all) let id: UInt64
        access(all) let name: String
        access(all) let description: String
        access(all) let itemType: ItemType
        access(all) let rarity: Rarity
        access(all) let stackable: Bool

        access(all) let weapon: WeaponData?
        access(all) let armour: ArmourData?
        access(all) let consumable: ConsumableData?
        access(all) let accessory: AccessoryData?
        access(all) let imgURL: String? 

        init(
            id: UInt64,
            name: String,
            description: String,
            itemType: ItemType,
            rarity: Rarity,
            stackable: Bool,
            weapon: WeaponData?,
            armour: ArmourData?,
            consumable: ConsumableData?,
            accessory: AccessoryData?
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.itemType = itemType
            self.rarity = rarity
            self.stackable = stackable
            self.weapon = weapon
            self.armour = armour
            self.consumable = consumable
            self.accessory = accessory
            self.imgURL = "ipfs://bafybeidhmg4d7gsiby2jrsilfkntoiq2aknreeeghmgfgltjqiacecpdey"
        }
   
        // Metadata Views support
        // access(all) fun resolveView(_ view: Type): AnyStruct? {
        //     switch view {
        //     case Type<MetadataViews.Display>():
        //         return MetadataViews.Display(
        //             name: self.name,
        //             description: self.description,
        //             thumbnail: MetadataViews.HTTPFile(url: "ipfs://bafybeidhmg4d7gsiby2jrsilfkntoiq2aknreeeghmgfgltjqiacecpdey")
        //         )
        //     default:
        //         return nil
        //     }
        // }
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-ItemManager.createEmptyCollection(nftType: Type<@ItemManager.NFT>())
        }
        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>()
            ]
        }
        access(all) fun resolveView(_ view: Type): AnyStruct? 
        {
            switch view 
            {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: "Avataaars #".concat(self.id.toString()),
                        description: "This is a procedurally generated avatar! You can learn more about it here: https://avataaars.com/",
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.imgURL ?? "ipfs://bafybeidhmg4d7gsiby2jrsilfkntoiq2aknreeeghmgfgltjqiacecpdey"
                        )
                    )
                case Type<MetadataViews.Traits>():
                    // dict must be a subset of `{String: AnyStruct}`, Avataaars uses `{String: String}`
                    let traits: {String: String} = {
                        "ID": self.id.toString(),
                        "Name": self.name,
                        "Type:": ItemManager.itemTypeToString(self.itemType),
                        "Rarity": ItemManager.rarityToString(self.rarity),
                        "Description": self.description,
                        "Stackable": self.stackable ? "Yes" : "No"  
                    }
                    if let weapon = self.weapon {
                        traits["Weapon Damage"] = weapon.damage.toString()
                        traits["Weapon Attack Speed"] = weapon.attackSpeed.toString()
                        traits["Weapon Critical Rate"] = weapon.criticalRate.toString()
                        traits["Weapon Critical Damage"] = weapon.criticalDamage.toString()
                    }
                    if let armour = self.armour {
                        traits["Armour Max Health"] = armour.maxHealth.toString()
                        traits["Armour Defense"] = armour.defense.toString()
                        traits["Armour Health Regen"] = armour.healthRegen.toString()
                    }
                    if let consumable = self.consumable {
                        traits["Consumable Health Affected"] = consumable.healthAffected.toString()
                        traits["Consumable Mana Affected"] = consumable.manaAffected.toString()
                        traits["Consumable Energy Affected"] = consumable.energyAffected.toString()
                        traits["Consumable Cooldown"] = consumable.cooldown.toString()
                        traits["Consumable Duration"] = consumable.duration.toString()
                    }
                    if let accessory = self.accessory {
                        traits["Accessory Bonus Energy"] = accessory.bonusEnergy.toString()
                        traits["Accessory Bonus Mana"] = accessory.bonusMana.toString()
                        traits["Accessory Bonus Mana Regen"] = accessory.bonusManaRegen.toString()
                        traits["Accessory Bonus Energy Regen"] = accessory.bonusEnergyRegen.toString()
                    }
                    let traitsView = MetadataViews.dictToTraits(dict: traits, excludedNames: [])
                    return traitsView
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return MetadataViews.NFTCollectionDisplay(
                            name: "Items",
                            description: "This collection is used showcase the various things you can do with metadata standards on Flowty",
                            externalURL: MetadataViews.ExternalURL("https://flowty.io/"),
                            squareImage: MetadataViews.Media(
                                file: MetadataViews.HTTPFile(
                                    url: "ipfs://bafybeidhmg4d7gsiby2jrsilfkntoiq2aknreeeghmgfgltjqiacecpdey"
                                ),
                                mediaType: "image/jpeg"
                            ),
                            bannerImage: MetadataViews.Media(
                                file: MetadataViews.HTTPFile(
                                    url: "https://storage.googleapis.com/flowty-images/flowty-banner.jpeg"
                                ),
                                mediaType: "image/jpeg"
                            ),
                            socials: {
                                "twitter": MetadataViews.ExternalURL("https://twitter.com/flowty_io")
                            }
                        )
                // 
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: ItemManager.CollectionStoragePath,
                        publicPath: ItemManager.CollectionPublicPath,
                        publicCollection: Type<&ItemManager.Collection>(),
                        publicLinkedType: Type<&ItemManager.Collection>(),
                        // providerLinkedType: Type<&Avataaars.Collection & Avataaars.AvataaarsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,ViewResolver.ResolverCollection>(),
                        createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                            return <-ItemManager.createEmptyCollection(nftType: Type<@ItemManager.NFT>())
                        })
                    )
                // truncated other metadata views...
            }
            return nil
        }
    }

    // ===== Resource: Collection =====
    // NOTE: ownedNFTs uses @NonFungibleToken.NFT as the stored resource type
    access(all) resource Collection: NonFungibleToken.Collection {
        access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}

        init() {
            self.ownedNFTs <- {}
        }
        access(all) view fun getIDs(): [UInt64] 
        {
            return self.ownedNFTs.keys
        }
        access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
            let nft <- token as! @NFT
            self.ownedNFTs[nft.id] <-! nft
        }

        access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID)
                    ?? panic("ItemManager.Collection.withdraw: Could not withdraw an NFT with ID "
                            .concat(withdrawID.toString())
                            .concat(". Check the submitted ID to make sure it is one that this collection owns."))

            return <-token
        }

        // access(all) fun borrowNFT(id: UInt64): &{NonFungibleToken.NFT} {
        //     let nftRef = &self.ownedNFTs[id] as &{NonFungibleToken.NFT}?
        //     ?? panic("NFT does not exist in this collection")

        //     return nftRef
        // }

        access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
            return &self.ownedNFTs[id]
        }
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@ItemManager.NFT>()
        }
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-ItemManager.createEmptyCollection(nftType: Type<@ItemManager.NFT>())
        }
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} 
        {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[Type<@ItemManager.NFT>()] = true
            return supportedTypes
        }
    }

    // ===== Admin & Minting Logic =====
    access(all) var totalSupply: UInt64
    access(all) var questManager: Address

    // public helper to create an empty collection (keeps compat with both patterns)
    access(all) fun createEmptyCollection(nftType: Type): @Collection {
        return <- create Collection()
    }

    // access(all) fun createEmptyCollection(): @Collection {
    //     return <- create Collection()
    // }

    access(contract) fun mint(
        recipient: &{NonFungibleToken.Receiver},
        name: String,
        description: String,
        itemType: ItemType,
        rarity: Rarity,
        stackable: Bool,
        weapon: WeaponData?,
        armour: ArmourData?,
        consumable: ConsumableData?,
        accessory: AccessoryData?
    ) {
        let newID = ItemManager.totalSupply
        ItemManager.totalSupply = ItemManager.totalSupply + UInt64(1)

        let nft <- create NFT(
            id: newID,
            name: name,
            description: description,
            itemType: itemType,
            rarity: rarity,
            stackable: stackable,
            weapon: weapon,
            armour: armour,
            consumable: consumable,
            accessory: accessory
        )
        emit Minted(
            id: nft.id,
            uuid: nft.uuid,
            minter: self.account.address,

            name: nft.name,
            description: nft.description,
            itemType: ItemManager.itemTypeToString(itemType),
            rarity: ItemManager.rarityToString(rarity),
            stackable: stackable,

            weapon: weapon != nil ? {
                "damage": weapon!.damage,
                "attackSpeed": weapon!.attackSpeed,
                "criticalRate": weapon!.criticalRate,
                "criticalDamage": weapon!.criticalDamage
            } : {},

            armour: armour != nil ? {
                "slot": armour!.slot.rawValue,
                "maxHealth": armour!.maxHealth,
                "defense": armour!.defense,
                "healthRegen": armour!.healthRegen,
                "resistances": armour!.resistances
            } : {},

            consumable: consumable != nil ? {
                "healthAffected": consumable!.healthAffected,
                "manaAffected": consumable!.manaAffected,
                "energyAffected": consumable!.energyAffected,
                "cooldown": consumable!.cooldown,
                "duration": consumable!.duration
            } : {},

            accessory: accessory != nil ? {
                "bonusEnergy": accessory!.bonusEnergy,
                "bonusMana": accessory!.bonusMana,
                "bonusManaRegen": accessory!.bonusManaRegen,
                "bonusEnergyRegen": accessory!.bonusEnergyRegen
            } : {},

            imgURL: nft.imgURL
    )

        recipient.deposit(token: <- nft)
    }
    access(all) fun mintItem(
        recipient: &{NonFungibleToken.Receiver},
        name: String,
        description: String,
        itemType: ItemType,
        rarity: Rarity,
        stackable: Bool,
        weapon: WeaponData?,
        armour: ArmourData?,
        consumable: ConsumableData?,
        accessory: AccessoryData?
    ) {
        self.mint(recipient: recipient, name: name, description: description, itemType: itemType, rarity: rarity, stackable: stackable, weapon: weapon, armour: armour, consumable: consumable, accessory: accessory)
    }

    access(all) resource NFTMinter {
        access(all) fun createNFT(
        name: String,
        description: String,
        itemType: ItemManager.ItemType,
        rarity: ItemManager.Rarity,
        stackable: Bool,
        weapon: ItemManager.WeaponData?,
        armour: ItemManager.ArmourData?,
        consumable: ItemManager.ConsumableData?,
        accessory: ItemManager.AccessoryData?): @NFT {
            let newID = ItemManager.totalSupply
            ItemManager.totalSupply = ItemManager.totalSupply + UInt64(1)

            let nft <- create NFT(
                id: newID,
                name: name,
                description: description,
                itemType: itemType,
                rarity: rarity,
                stackable: stackable,
                weapon: weapon,
                armour: armour,
                consumable: consumable,
                accessory: accessory
            )
            emit ItemManager.Minted(
                id: nft.id,
                uuid: nft.uuid,
                minter: self.owner!.address,

                name: nft.name,
                description: nft.description,
                itemType: ItemManager.itemTypeToString(itemType),
                rarity: ItemManager.rarityToString(rarity),
                stackable: stackable,

                weapon: weapon != nil ? {
                    "damage": weapon!.damage,
                    "attackSpeed": weapon!.attackSpeed,
                    "criticalRate": weapon!.criticalRate,
                    "criticalDamage": weapon!.criticalDamage
                } : {},

                armour: armour != nil ? {
                    "slot": armour!.slot.rawValue,
                    "maxHealth": armour!.maxHealth,
                    "defense": armour!.defense,
                    "healthRegen": armour!.healthRegen,
                    "resistances": armour!.resistances
                } : {},

                consumable: consumable != nil ? {
                    "healthAffected": consumable!.healthAffected,
                    "manaAffected": consumable!.manaAffected,
                    "energyAffected": consumable!.energyAffected,
                    "cooldown": consumable!.cooldown,
                    "duration": consumable!.duration
                } : {},

                accessory: accessory != nil ? {
                    "bonusEnergy": accessory!.bonusEnergy,
                    "bonusMana": accessory!.bonusMana,
                    "bonusManaRegen": accessory!.bonusManaRegen,
                    "bonusEnergyRegen": accessory!.bonusEnergyRegen
                } : {},

                imgURL: nft.imgURL
            )

            return <- nft
        }

        init() {}
    }


    init() {
        // initialize manager state
        self.totalSupply = 1
        self.questManager = 0x01
        self.CollectionStoragePath = /storage/ItemManagerNFTCollection
        self.CollectionPublicPath = /public/ItemManagerNFTCollection
        self.MinterStoragePath = /storage/ItemManagerNFTMinter
        self.account.storage.save(<- create NFTMinter(), to: self.MinterStoragePath)
    }
}