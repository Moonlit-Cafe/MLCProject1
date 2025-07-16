## This acts as a middle-layer where if I need strings, but want the consistency of Enums.
class_name GenumHelper

## Used to get the name of an Audio Bus based on its corresponding Enum in [class Genum]
const BUS_NAME : Dictionary[Genum.BusID, String] = {
	Genum.BusID.MASTER: &"Master",
	Genum.BusID.OST: &"OST",
	Genum.BusID.SFX: &"SFX",
	Genum.BusID.UI: &"UI",
	Genum.BusID.AMBIENT: &"Ambient"
}

const ITEM_TIER : Dictionary[StringName, Genum.ItemTier] = {
	&"motal": Genum.ItemTier.MOTAL,
	&"pebbled": Genum.ItemTier.PEBBLED,
	&"cometary": Genum.ItemTier.COMETARY,
	&"planetary": Genum.ItemTier.PLANETARY,
	&"stellar": Genum.ItemTier.STELLAR,
	&"nebulous": Genum.ItemTier.NEBULOUS,
	&"cosmic": Genum.ItemTier.COSMIC
}
