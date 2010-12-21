module TaggingsHelper
  def add_remove(tagging)
    tagging.selectable? ? "add" : "remove"
  end
end
