extends RichTextLabel


func _ready():
	connect("meta_clicked", self, "meta_clicked")
	
	
func meta_clicked(meta: String):
	if meta.begins_with('"') and meta.ends_with('"'):
		meta = meta.substr(1, meta.length() - 2)
	if meta.begins_with("http://") or meta.begins_with("https://"):
		OS.shell_open(meta)
