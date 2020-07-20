resource "google_firestore_index" "composite-name-location-asc" {
    project           = var.project
    collection        = var.collection
    database          = "(default)"
    
    fields {
      field_path      = "name_first_letter"
      order           = "ASCENDING"
    }
    fields {
      array_config    = "CONTAINS"
      field_path      = "location_tags"
    }
    fields {
      field_path      = "__name__"
      order           = "ASCENDING"
    }
}

resource "google_firestore_index" "composite-name-location-dsc" {
    project           = var.project
    collection        = var.collection
    database          = "(default)"
    
    fields {
      field_path      = "name_first_letter"
      order           = "DESCENDING"
    }
    fields {
      array_config    = "CONTAINS"
      field_path      = "location_tags"
    }
    fields {
      field_path      = "__name__"
      order           = "ASCENDING"
    }
}

resource "google_firestore_index" "composite-name-genre-asc" {
    project           = var.project
    collection        = var.collection
    database          = "(default)"

    fields {
      field_path      = "name_first_letter"
      order           = "ASCENDING"
    }
    fields {
      array_config    = "CONTAINS"
      field_path      = "genre_tags"
    }
    fields {
      field_path      = "__name__"
      order           = "ASCENDING"
    }
}

resource "google_firestore_index" "composite-name-genre-dsc" {
    project           = var.project
    collection        = var.collection
    database          = "(default)"
    
    fields {
      field_path      = "name_first_letter"
      order           = "DESCENDING"
    }
    fields {
      array_config    = "CONTAINS"
      field_path      = "genre_tags"
    }
    fields {
      field_path      = "__name__"
      order           = "ASCENDING"
    }
}
