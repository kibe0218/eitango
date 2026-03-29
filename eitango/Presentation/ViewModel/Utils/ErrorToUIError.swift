
func ErrorToUIAlertError (_ error: Error) -> UIError {
    let appError = ErrorMapper.map(error)
    let message = ErrorMapper.toMessage(appError)
    return .alert(message)
}

func ErrorToUIToastError (_ error: Error) -> UIError {
    let appError = ErrorMapper.map(error)
    let message = ErrorMapper.toMessage(appError)
    return .toast(message)
}

