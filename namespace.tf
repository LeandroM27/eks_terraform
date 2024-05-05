resource "kubernetes_namespace" "apps" {
  metadata {
    name = "dev"
    labels = {
      prometheus = "prometheus"
    }
  }
}
