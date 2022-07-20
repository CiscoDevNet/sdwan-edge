provider "google" {
  credentials = file("~/gcp/gcp.json")
  project = "your_project"
}