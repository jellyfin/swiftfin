//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import JellyfinAPI
import SwiftUI

protocol EpisodesRowManager: ViewModel {
	var item: BaseItemDto { get }
	var seasonsEpisodes: [BaseItemDto: [BaseItemDto]] { get set }
	var selectedSeason: BaseItemDto? { get set }
	func getSeasons()
	func getEpisodesForSeason(_ season: BaseItemDto)
	func select(season: BaseItemDto)
}

extension EpisodesRowManager {

	var sortedSeasons: [BaseItemDto] {
		Array(seasonsEpisodes.keys).sorted(by: { $0.indexNumber ?? 0 < $1.indexNumber ?? 0 })
	}

	// Also retrieves the current season episodes if available
	func getSeasons() {
		TvShowsAPI.getSeasons(seriesId: item.id ?? "",
		                      userId: SessionManager.main.currentLogin.user.id,
		                      isMissing: Defaults[.shouldShowMissingSeasons] ? nil : false)
			.sink { completion in
				self.handleAPIRequestError(completion: completion)
			} receiveValue: { response in
				let seasons = response.items ?? []

				seasons.forEach { season in
					self.seasonsEpisodes[season] = []
				}

//				seasons.forEach { season in
//					self.seasonsEpisodes[season] = []
//
//					if season.id == self.item.seasonId ?? "" {
//						self.selectedSeason = season
//						self.getEpisodesForSeason(season)
//					} else if season.id == self.item.id ?? "" {
//						self.selectedSeason = season
//						self.getEpisodesForSeason(season)
//					}
//				}

				self.selectedSeason = seasons.first
			}
			.store(in: &cancellables)
	}

	func getEpisodesForSeason(_ season: BaseItemDto) {
		guard let seasonID = season.id else { return }

		TvShowsAPI.getEpisodes(seriesId: item.id ?? "",
		                       userId: SessionManager.main.currentLogin.user.id,
		                       fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people],
		                       seasonId: seasonID,
		                       isMissing: Defaults[.shouldShowMissingEpisodes] ? nil : false)
			.trackActivity(loading)
			.sink { completion in
				self.handleAPIRequestError(completion: completion)
			} receiveValue: { episodes in
				self.seasonsEpisodes[season] = episodes.items ?? []
			}
			.store(in: &cancellables)
	}

	func select(season: BaseItemDto) {
		self.selectedSeason = season

		if seasonsEpisodes[season]!.isEmpty {
			getEpisodesForSeason(season)
		}
	}
}
