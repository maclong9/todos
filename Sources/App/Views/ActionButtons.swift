struct ActionButtons {
    let isNavigation: Bool
    
    init(isNavigation: Bool = false) {
        self.isNavigation = isNavigation
    }
    
    func render() -> String {
        """
        <div class="btn-group \(isNavigation ? "col" : "")">
        <a
            href="/signup"
            class="btn"
            >Get Started</a
          >
          <a href="https://apple.com/uk/app-store" class="btn primary">
            Get the App
          </a>
        </div>
        """
    }
}
