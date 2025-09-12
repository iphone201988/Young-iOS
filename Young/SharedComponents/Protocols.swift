
protocol SelectedUsers {
    func users(_ users: [UserDetails])
}

protocol Exchange {
    func reloadContent(for event: SavedOptions)
    func updateRating(for event: SavedOptions, id: String, rating: Double)
    func updateCommentCount(for event: SavedOptions, id: String)
    func updateReportStatus(for event: SavedOptions, id: String)
}
