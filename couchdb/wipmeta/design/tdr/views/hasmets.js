module.exports = {
  map: function(doc) {
    if ("_attachments" in doc || "label" in doc) {
      emit(doc.updated, null);
    }
  },
  reduce: "_count"
};
