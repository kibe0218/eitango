protocol ErrorHandleable {
    var appState: AppState { get }
}

extension ErrorHandleable {
    func handleError(_ error: Error) {
        let appError = ErrorMapper.map(error)
        let message = ErrorMapper.toMessage(appError)
        appState.error = .alert(message)
    }
}
