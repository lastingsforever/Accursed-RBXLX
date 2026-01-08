--!strict

-- Types
export type FirstName =
"None"
| "Dogen"
| "Michi"
| "Haruto"
| "Ren"
| "Sora"
| "Riku"
| "Yuto"
| "Kaito"
| "Daichi"
| "Takumi"
| "Ryota"
| "Shota"
| "Keita"
| "Tsubasa"
| "Akira"
| "Itsuki"
| "Minato"
| "Hibiki"
| "Hayato"
| "Shin"
| "Kenji"
| "Koji"
| "Naoki"
| "Yuki"
| "Kenta"
| "Toru"
| "Hiro"
| "Nobu"
| "Aoi"
| "Rei"

export type LastName =
"None"
| "Itadori"
| "Fushiguro"
| "Kugisaki"
| "Gojo"
| "Zenin"
| "Inumaki"
| "Panda"
| "Okkotsu"
| "Geto"
| "Ieiri"
| "Nanami"
| "Kusakabe"
| "Yaga"
| "Gakuganji"
| "Utahime"
| "Mei"
| "Nitta"
| "Hakari"
| "Hoshino"
| "Kamo"
| "Tsukumo"
| "Yoshino"
| "Jogo"
| "Hanami"
| "Dagon"
| "Mahito"
| "Sukuna"

export type HairColor = "None" | "Brown" | "Black" | "DarkRed" | "White" | "Blonde"

-- Variables
local NameLibrary = {}
NameLibrary.FirstNames = {
	"None",
	"Dogen",
	"Michi",
	"Haruto",
	"Ren",
	"Sora",
	"Riku",
	"Yuto",
	"Kaito",
	"Daichi",
	"Takumi",
	"Ryota",
	"Shota",
	"Keita",
	"Tsubasa",
	"Akira",
	"Itsuki",
	"Minato",
	"Hibiki",
	"Hayato",
	"Shin",
	"Kenji",
	"Koji",
	"Naoki",
	"Yuki",
	"Kenta",
	"Toru",
	"Hiro",
	"Nobu",
	"Aoi",
	"Rei",
} :: { FirstName }

NameLibrary.LastNames = {
	"None",
	"Itadori",
	"Fushiguro",
	"Kugisaki",
	"Gojo",
	"Zenin",
	"Inumaki",
	"Panda",
	"Okkotsu",
	"Geto",
	"Ieiri",
	"Nanami",
	"Kusakabe",
	"Yaga",
	"Gakuganji",
	"Utahime",
	"Mei",
	"Nitta",
	"Hakari",
	"Hoshino",
	"Kamo",
	"Tsukumo",
	"Yoshino",
	"Jogo",
	"Hanami",
	"Dagon",
	"Mahito",
	"Sukuna",
} :: { LastName }

NameLibrary.HairColors = {
	"None",
	"Brown",
	"Black",
	"DarkRed",
	"White",
	"Blonde",
} :: { HairColor }

-- Module
function NameLibrary.RandomFirstName(): FirstName
	local MyRandom = Random.new()
	return NameLibrary.FirstNames[MyRandom:NextInteger(1, #NameLibrary.FirstNames)]
end

function NameLibrary.RandomLastName(): LastName
	local MyRandom = Random.new()
	return NameLibrary.LastNames[MyRandom:NextInteger(1, #NameLibrary.LastNames)]
end

function NameLibrary.RandomHairColor(): HairColor
	local MyRandom = Random.new()
	return NameLibrary.HairColors[MyRandom:NextInteger(1, #NameLibrary.HairColors)] :: HairColor
end

-- Script
return NameLibrary
