extends Node

signal freeing_orphans

func free_orphaned_nodes():
	emit_signal("freeing_orphans")
