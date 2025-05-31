import Foundation

struct Theme: Codable {
    let nameKey: String
    let words: [String]
    
    var localizedName: String {
        return nameKey.localized
    }
}


let foodTheme = Theme(nameKey: "theme_food", words: [
    "word_pizza", "word_sushi", "word_potato", "word_dumplings", "word_cake", "word_porridge", "word_kebab", "word_salad", "word_burger", "word_bread",
    "word_icecream", "word_cheese", "word_yogurt", "word_cucumber", "word_tomato", "word_rolls", "word_chips", "word_coffee", "word_tea", "word_lemonade",
    "word_juice", "word_pancakes", "word_pilaf", "word_noodles", "word_chicken", "word_fish", "word_apple", "word_pear", "word_banana", "word_kiwi",
    "word_mandarin", "word_orange", "word_pineapple", "word_grapefruit", "word_honey", "word_chocolate", "word_candy", "word_muffin", "word_cookie", "word_jam"
])


let animalsTheme = Theme(nameKey: "theme_animals", words: [
    "word_cat", "word_dog", "word_rabbit", "word_penguin", "word_giraffe", "word_donkey", "word_fox", "word_tiger", "word_lion", "word_monkey",
    "word_cow", "word_chicken", "word_duck", "word_sheep", "word_goat", "word_kangaroo", "word_crocodile", "word_snake", "word_horse", "word_hedgehog",
    "word_elephant", "word_bear", "word_wolf", "word_rooster", "word_swan", "word_goose", "word_dolphin", "word_shark", "word_whale", "word_parrot",
    "word_owl", "word_beetle", "word_spider", "word_ant", "word_ladybug", "word_bee", "word_mosquito", "word_fly", "word_moth", "word_scorpion"
])


let jobsTheme = Theme(nameKey: "theme_jobs", words: [
    "word_teacher", "word_chef", "word_firefighter", "word_actor", "word_police", "word_blogger", "word_doctor", "word_surgeon", "word_writer", "word_artist",
    "word_musician", "word_programmer", "word_marketer", "word_manager", "word_designer", "word_architect", "word_mechanic", "word_hairdresser", "word_plumber", "word_florist",
    "word_photographer", "word_agronomist", "word_farmer", "word_driver", "word_pilot", "word_builder", "word_lawyer", "word_accountant", "word_attorney", "word_vet",
    "word_translator", "word_editor", "word_director", "word_engineer", "word_economist", "word_astronomer", "word_physicist", "word_chemist", "word_psychologist", "word_psychiatrist"
])

let transportTheme = Theme(nameKey: "theme_transport", words: [
    "word_car", "word_airplane", "word_bicycle", "word_ship", "word_train", "word_scooter", "word_bus", "word_metro", "word_tram", "word_trolleybus",
    "word_truck", "word_taxi", "word_motorcycle", "word_boat_small", "word_yacht", "word_helicopter", "word_kick_scooter", "word_van", "word_snowmobile", "word_atv",
    "word_cart", "word_steam_locomotive", "word_shuttle", "word_boat", "word_elevator", "word_funicular", "word_platform", "word_sedan", "word_coupe", "word_cabriolet",
    "word_pickup", "word_minivan", "word_limo", "word_carriage", "word_hoverboard", "word_monorail", "word_escalator", "word_horse_transport", "word_drone", "word_catamaran"
])


let moviesTheme = Theme(nameKey: "theme_movies", words: [
    "word_titanic", "word_matrix", "word_harry_potter", "word_shrek", "word_avatar", "word_cheburashka", "word_forrest_gump", "word_pirates", "word_lotr", "word_hobbit",
    "word_doctor_strange", "word_avengers", "word_iron_man", "word_gladiator", "word_hulk", "word_spiderman", "word_joker", "word_batman", "word_fantastic_beasts", "word_interstellar",
    "word_inception", "word_gravity", "word_revenant", "word_ratatouille", "word_lion_king", "word_toy_story", "word_up", "word_cars", "word_inside_out", "word_sex_city",
    "word_kungfu_panda", "word_zootopia", "word_frozen", "word_incredibles", "word_wall_e", "word_coco", "word_smeshariki", "word_bremen_musicians", "word_nu_pogodi", "word_hedgehog_fog"
])


let travelTheme = Theme(nameKey: "theme_travel", words: [
    "word_airport_terminal", "word_luggage_tag", "word_passport_stamp", "word_boarding_pass", "word_window_seat",
    "word_customs_control", "word_lost_baggage", "word_travel_adapter", "word_guidebook", "word_currency_exchange",
    "word_hiking_boots", "word_souvenir_shop", "word_local_market", "word_street_food", "word_travel_diary",
    "word_postcard_home", "word_eiffel_tower", "word_city_map", "word_sunset_beach", "word_mountain_peak",
    "word_hostel_bunk", "word_travel_backpack", "word_metro_ticket", "word_local_language", "word_train_station",
    "word_flight_delay", "word_night_bus", "word_hotel_lobby", "word_cultural_festival", "word_airplane_meal",
    "word_landing_announcement", "word_tourist_spot", "word_cruise_ship", "word_sightseeing_tour", "word_travel_insurance",
    "word_border_crossing", "word_nature_trail", "word_travel_photo", "word_travel_guide", "word_travel_snacks",
    "word_city_square", "word_national_park", "word_beach_resort", "word_lake_view", "word_walking_tour",
    "word_compass", "word_cabin_bag", "word_train_tracks", "word_road_trip", "word_map_pin"
])


let adultsThemes: [Theme] = [
    Theme(nameKey: "theme_adult", words: [
        "word_condom", "word_bdsm", "word_roleplay", "word_impotence", "word_flirt", "word_g_spot", "word_dildo", "word_striptease", "word_seduction", "word_rimming",
        "word_sex", "word_fetish", "word_exhibitionism", "word_hug", "word_fantasy", "word_porn", "word_position", "word_foreplay", "word_fertility", "word_ejaculation",
        "word_intercrural", "word_footfisting", "word_intimacy", "word_date", "word_cunnilingus", "word_relaxation", "word_hand", "word_lips", "word_body",
        "word_transgender", "word_blowjob", "word_secret", "word_desire", "word_moan", "word_anal_plug", "word_vibrator", "word_golden_shower", "word_vodka", "word_tequila",
        "word_hangover", "word_hookah", "word_bartender", "word_disco", "word_cocktail", "word_drunk", "word_noise", "word_home_video", "word_pole_dance", "word_repeat_strip"
    ])
    
]

let allThemes: [Theme] = [
    foodTheme,
    animalsTheme,
    jobsTheme,
    transportTheme,
    moviesTheme,
    travelTheme,
] + adultsThemes

var customTheme: Theme? {
    get {
        if let data = UserDefaults.standard.data(forKey: "custom_theme"),
           let theme = try? JSONDecoder().decode(Theme.self, from: data) {
            return theme
        }
        return nil
    }
    set {
        if let theme = newValue,
           let data = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(data, forKey: "custom_theme")
        } else {
            UserDefaults.standard.removeObject(forKey: "custom_theme")
        }
    }
}
func updateCustomTheme(with words: [String]) {
    customTheme = Theme(nameKey: "theme_custom", words: words)
}
func getAllThemesIncludingCustom() -> [Theme] {
    var themes = allThemes
    if let custom = customTheme {
        themes.append(custom)
    }
    return themes
}
