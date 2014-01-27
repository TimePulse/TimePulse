// Favicon.js - Change favicon dynamically [http://ajaxify.com/run/favicon].
// Copyright (c) 2006 Michael Mahemoff. Only works in Firefox and Opera.
// Background and MIT License notice at end of file, see the homepage for more.

var favicon = {

  // -- "PUBLIC" ----------------------------------------------------------------

  change: function(iconURL, optionalDocTitle, mimeType) {
    if (optionalDocTitle) {
      document.title = optionalDocTitle;
    }
    this.addLink(iconURL, mimeType);
  },

  // -- "PRIVATE" ---------------------------------------------------------------

  preloadIcons: function(iconSequence) {
    var dummyImageForPreloading = document.createElement("img");
    for (var i=0; i<iconSequence.length; i++) {
      dummyImageForPreloading.src = iconSequence[i];
    }
  },

  addLink: function(iconURL, type) {
    var link = document.createElement("link");
    link.type = type || "image/x-icon";
    link.rel = "shortcut icon";
    link.href = iconURL;
    this.removeLinkIfExists();
    this.docHead.appendChild(link);
  },

  removeLinkIfExists: function() {
    var links = this.docHead.getElementsByTagName("link");
    for (var i=0; i<links.length; i++) {
      var link = links[i];
      if (link.rel=="shortcut icon") {
        this.docHead.removeChild(link);
      }
    }
  },

  docHead:document.getElementsByTagName("head")[0]
}
