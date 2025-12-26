import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
import ViewResolver from 0x631e88ae7f1d7c20

access(all) contract HeroNFT: NonFungibleToken {

    access(all) event Minted(
    type: String,
    id: UInt64,
    uuid: UInt64,
    minterAddress: Address,

    // HeroData fields
    playerName: String,
    playerID: String,
    level: UInt32,
    isBanned: Bool,
    raceName: String,
    equippedItems: [String],

    // Stats fields
    offensiveStats: {String: UInt32},
    defensiveStats: {String: UInt32},
    specialStats: {String: UInt32},
    craftingStats: {String: UInt32},
    survivalStats: {String: UInt32},

    // Metadata
    imgURL: String?
)


    access(all) struct OffensiveStats {
        access(all) let damage: UInt32
        access(all) let attackSpeed: UInt32
        access(all) let criticalRate: UInt32
        access(all) let criticalDamage: UInt32

        init(damage: UInt32, attackSpeed: UInt32, criticalRate: UInt32, criticalDamage: UInt32) {
            self.damage = damage
            self.attackSpeed = attackSpeed
            self.criticalRate = criticalRate
            self.criticalDamage = criticalDamage
        }
    }

    access(all) struct DefensiveStats {
        access(all) let maxHealth: UInt32
        access(all) let defense: UInt32
        access(all) let healthRegeneration: UInt32
        access(all) let resistances: [UInt32]

        init(maxHealth: UInt32, defense: UInt32, healthRegeneration: UInt32, resistances: [UInt32]) {
            self.maxHealth = maxHealth
            self.defense = defense
            self.healthRegeneration = healthRegeneration
            self.resistances = resistances
        }
    }

    access(all) struct SpecialStats {
        access(all) let maxEnergy: UInt32
        access(all) let energyRegeneration: UInt32
        access(all) let maxMana: UInt32
        access(all) let manaRegeneration: UInt32

        init(maxEnergy: UInt32, energyRegeneration: UInt32, maxMana: UInt32, manaRegeneration: UInt32) {
            self.maxEnergy = maxEnergy
            self.energyRegeneration = energyRegeneration
            self.maxMana = maxMana
            self.manaRegeneration = manaRegeneration
        }
    }

    access(all) struct StatPointsAssigned {
        access(all) let constitution: UInt32
        access(all) let strength: UInt32
        access(all) let dexterity: UInt32
        access(all) let intelligence: UInt32
        access(all) let stamina: UInt32
        access(all) let agility: UInt32
        access(all) let remainingPoints: UInt32

        init(constitution: UInt32, strength: UInt32, dexterity: UInt32, intelligence: UInt32, stamina: UInt32, agility: UInt32, remainingPoints: UInt32) {
            self.constitution = constitution
            self.strength = strength
            self.dexterity = dexterity
            self.intelligence = intelligence
            self.stamina = stamina
            self.agility = agility
            self.remainingPoints = remainingPoints
        }
    }

    access(all) struct Stats {
        access(all) let offensiveStats: OffensiveStats
        access(all) let defensiveStats: DefensiveStats
        access(all) let specialStats: SpecialStats
        access(all) let statPointsAssigned: StatPointsAssigned

        init(offensiveStats: OffensiveStats, defensiveStats: DefensiveStats, specialStats: SpecialStats, statPointsAssigned: StatPointsAssigned) {
            self.offensiveStats = offensiveStats
            self.defensiveStats = defensiveStats
            self.specialStats = specialStats
            self.statPointsAssigned = statPointsAssigned
        }
    }

    access(all) struct HeroData {
        access(all) let playerName: String
        access(all) let playerID: String
        access(all) let level: UInt32
        access(all) let isBanned: Bool
        access(all) let raceName: String
        access(all) let equippedItems: [String]
        access(all) let stats: Stats

        init(playerName: String, playerID: String, level: UInt32, isBanned: Bool, raceName: String, equippedItems: [String], stats: Stats) {
            self.playerName = playerName
            self.playerID = playerID
            self.level = level
            self.isBanned = isBanned
            self.raceName = raceName
            self.equippedItems = equippedItems
            self.stats = stats
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
                    publicCollection: Type<&HeroNFT.Collection>(),
                    publicLinkedType: Type<&HeroNFT.Collection>(),
                    createEmptyCollectionFunction: (fun(): @{NonFungibleToken.Collection} {
                        return <-HeroNFT.createEmptyCollection(nftType: Type<@HeroNFT.NFT>())
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
                    name: "The HeroNFT Example Collection",
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

    access(all) resource NFT: NonFungibleToken.NFT, ViewResolver.Resolver {
        access(all) let id: UInt64
        access(all) var heroData: HeroData
        access(all) let imgURL: String? 

        init(
            id: UInt64,
            heroData: HeroData,
            imgURL: String?
        ) {
            self.id = id
            self.heroData = heroData
            self.imgURL = imgURL
        }

        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-HeroNFT.createEmptyCollection(nftType: Type<@HeroNFT.NFT>())
        }
        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Editions>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Serial>(),
                Type<MetadataViews.Traits>()
            ]
        }
        access(all) fun resolveView(_ view: Type): AnyStruct? 
        {
            switch view 
            {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.heroData.playerName.concat(" #").concat(self.id.toString()),
                        description: "A hero of race ".concat(self.heroData.raceName).concat(" at level ").concat(self.heroData.level.toString()),
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.imgURL ?? "ipfs://bafybeidhmg4d7gsiby2jrsilfkntoiq2aknreeeghmgfgltjqiacecpdey"
                        )
                    )
                case Type<MetadataViews.Traits>():
                    let traits: {String: AnyStruct} = {
                        "Player ID": self.heroData.playerID,
                        "Level": self.heroData.level,
                        "Is Banned": self.heroData.isBanned ? "Yes" : "No",
                        "Race Name": self.heroData.raceName,
                        "Equipped Items": self.heroData.equippedItems
                    }
                    // Add stats as sub-traits
                    let stats = self.heroData.stats
                    traits["Damage"] = stats.offensiveStats.damage
                    traits["Attack Speed"] = stats.offensiveStats.attackSpeed
                    traits["Critical Rate"] = stats.offensiveStats.criticalRate
                    traits["Critical Damage"] = stats.offensiveStats.criticalDamage
                    traits["Max Health"] = stats.defensiveStats.maxHealth
                    traits["Defense"] = stats.defensiveStats.defense
                    traits["Health Regeneration"] = stats.defensiveStats.healthRegeneration
                    traits["Resistances"] = stats.defensiveStats.resistances
                    traits["Max Energy"] = stats.specialStats.maxEnergy
                    traits["Energy Regeneration"] = stats.specialStats.energyRegeneration
                    traits["Max Mana"] = stats.specialStats.maxMana
                    traits["Mana Regeneration"] = stats.specialStats.manaRegeneration
                    traits["Constitution"] = stats.statPointsAssigned.constitution
                    traits["Strength"] = stats.statPointsAssigned.strength
                    traits["Dexterity"] = stats.statPointsAssigned.dexterity
                    traits["Intelligence"] = stats.statPointsAssigned.intelligence
                    traits["Stamina"] = stats.statPointsAssigned.stamina
                    traits["Agility"] = stats.statPointsAssigned.agility
                    traits["Remaining Points"] = stats.statPointsAssigned.remainingPoints

                    return MetadataViews.dictToTraits(dict: traits, excludedNames: [])
                case Type<MetadataViews.NFTCollectionDisplay>():
                    return MetadataViews.NFTCollectionDisplay(
                            name: "Heroes",
                            description: "This collection showcases hero NFTs on Flow.",
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
                case Type<MetadataViews.NFTCollectionData>():
                    return MetadataViews.NFTCollectionData(
                        storagePath: HeroNFT.CollectionStoragePath,
                        publicPath: HeroNFT.CollectionPublicPath,
                        publicCollection: Type<&HeroNFT.Collection>(),
                        publicLinkedType: Type<&HeroNFT.Collection>(),
                        createEmptyCollectionFunction: (fun (): @{NonFungibleToken.Collection} {
                            return <-HeroNFT.createEmptyCollection(nftType: Type<@HeroNFT.NFT>())
                        })
                    )
            }
            return nil
        }
        access(all) fun updateHeroStats(
            newStats: Stats
        ) {
            self.heroData = HeroData(
                playerName: self.heroData.playerName,
                playerID: self.heroData.playerID,
                level: self.heroData.level,
                isBanned: self.heroData.isBanned,
                raceName: self.heroData.raceName,
                equippedItems: self.heroData.equippedItems,
                stats: newStats
            )
        }
    }

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
            if self.ownedNFTs.length > 0 {
                panic("This collection can only hold one Hero NFT")
            }
            let nft <- token as! @NFT
            self.ownedNFTs[nft.id] <-! nft
        }

        access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID)
                    ?? panic("HeroNFT.Collection.withdraw: Could not withdraw an NFT with ID "
                            .concat(withdrawID.toString())
                            .concat(". Check the submitted ID to make sure it is one that this collection owns."))

            return <-token
        }

        access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
            return &self.ownedNFTs[id]
        }
        access(all) view fun isSupportedNFTType(type: Type): Bool {
            return type == Type<@HeroNFT.NFT>()
        }
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-HeroNFT.createEmptyCollection(nftType: Type<@HeroNFT.NFT>())
        }
        access(all) view fun getSupportedNFTTypes(): {Type: Bool} 
        {
            let supportedTypes: {Type: Bool} = {}
            supportedTypes[Type<@HeroNFT.NFT>()] = true
            return supportedTypes
        }
    }

    access(all) var totalSupply: UInt64
    access(all) var questManager: Address

    access(all) fun createEmptyCollection(nftType: Type): @Collection {
        return <- create Collection()
    }

    access(contract) fun mint(
        recipient: &{NonFungibleToken.Receiver},
        playerName: String,
        playerID: String,
        level: UInt32,
        isBanned: Bool,
        raceName: String,
        equippedItems: [String],
        stats: Stats,
        imgURL: String?
    ) {

        let heroData = HeroData(
            playerName: playerName,
            playerID: playerID,
            level: level,
            isBanned: isBanned,
            raceName: raceName,
            equippedItems: equippedItems,
            stats: stats
        )

        let nft <- create NFT(
            id: 1,
            heroData: heroData,
            imgURL: imgURL
        )

        emit Minted(
    type: "HeroNFT",
    id: nft.id,
    uuid: nft.uuid,
    minterAddress: self.account.address,

    playerName: heroData.playerName,
    playerID: heroData.playerID,
    level: heroData.level,
    isBanned: heroData.isBanned,
    raceName: heroData.raceName,
    equippedItems: heroData.equippedItems,

    offensiveStats: {
        "damage": heroData.stats.offensiveStats.damage,
        "attackSpeed": heroData.stats.offensiveStats.attackSpeed,
        "criticalRate": heroData.stats.offensiveStats.criticalRate,
        "criticalDamage": heroData.stats.offensiveStats.criticalDamage
    },
    defensiveStats: {
        "maxHealth": heroData.stats.defensiveStats.maxHealth,
        "defense": heroData.stats.defensiveStats.defense,
        "healthRegeneration": heroData.stats.defensiveStats.healthRegeneration
        // ⚠ if you want resistances array here, we’ll flatten or JSON encode it
    },
    specialStats: {
        "maxEnergy": heroData.stats.specialStats.maxEnergy,
        "energyRegeneration": heroData.stats.specialStats.energyRegeneration,
        "maxMana": heroData.stats.specialStats.maxMana,
        "manaRegeneration": heroData.stats.specialStats.manaRegeneration
    },
    craftingStats: {}, // you can drop or fill as needed
    survivalStats: {}, // you can drop or fill as needed

    imgURL: imgURL
)

        recipient.deposit(token: <- nft)
    }
    access(all) fun mintHero(
        recipient: &{NonFungibleToken.Receiver},
        playerName: String,
        playerID: String,
        level: UInt32,
        isBanned: Bool,
        raceName: String,
        equippedItems: [String],
        stats: Stats,
        imgURL: String?
    ) {
        self.mint(recipient: recipient, playerName: playerName, playerID: playerID, level: level, isBanned: isBanned, raceName: raceName, equippedItems: equippedItems, stats: stats, imgURL: imgURL)
    }

    access(all) resource NFTMinter {
        access(all) fun createNFT(id: UInt64,
        playerName: String,
        playerID: String,
        level: UInt32,
        isBanned: Bool,
        raceName: String,
        equippedItems: [String],
        stats: Stats,
        imgURL: String?): @NFT {
            let heroData = HeroData(
                playerName: playerName,
                playerID: playerID,
                level: level,
                isBanned: isBanned,
                raceName: raceName,
                equippedItems: equippedItems,
                stats: stats
            )
            return <-create NFT(id: id, heroData: heroData, imgURL: imgURL)
        }


        init() {}
    }

    init() {
        self.totalSupply = 1
        self.questManager = 0x01
        self.CollectionStoragePath = /storage/HeroNFTCollection
        self.CollectionPublicPath = /public/HeroNFTCollection
        self.MinterStoragePath = /storage/HeroNFTMinter
        self.account.storage.save(<- create NFTMinter(), to: self.MinterStoragePath)
    }
}