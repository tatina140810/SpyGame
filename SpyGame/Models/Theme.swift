import Foundation

struct Theme: Codable {
    let nameKey: String
    let words: [String]

    var localizedName: String {
        return nameKey.localized
    }
}

// MARK: - Refreshed word lists (40 words each).
// Picked for party play: single concept, recognisable to everyone, 5-10 obvious
// associations so spies can plausibly bluff and innocent players can hint without
// blowing the cover.

let foodTheme = Theme(nameKey: "theme_food", words: [
    "word_pizza", "word_sushi", "word_burger", "word_bread", "word_cheese",
    "word_sausage", "word_kebab", "word_pilaf", "word_borscht", "word_dumplings",
    "word_pancakes", "word_salad", "word_soup", "word_porridge", "word_egg",
    "word_milk", "word_icecream", "word_chocolate", "word_candy", "word_cake",
    "word_cookie", "word_apple", "word_banana", "word_grape", "word_watermelon",
    "word_melon", "word_lemon", "word_orange", "word_tomato", "word_cucumber",
    "word_potato", "word_onion", "word_carrot", "word_rice", "word_pasta",
    "word_chicken", "word_fish", "word_meat", "word_tea", "word_coffee"
])

let animalsTheme = Theme(nameKey: "theme_animals", words: [
    "word_dog", "word_cat", "word_cow", "word_horse", "word_sheep",
    "word_goat", "word_pig", "word_chicken", "word_rooster", "word_duck",
    "word_goose", "word_rabbit", "word_lion", "word_tiger", "word_elephant",
    "word_giraffe", "word_zebra", "word_monkey", "word_crocodile", "word_hippo",
    "word_bear", "word_wolf", "word_fox", "word_hare", "word_squirrel",
    "word_hedgehog", "word_mouse", "word_fish", "word_shark", "word_dolphin",
    "word_whale", "word_turtle", "word_snake", "word_frog", "word_butterfly",
    "word_bee", "word_ant", "word_spider", "word_eagle", "word_parrot"
])

let jobsTheme = Theme(nameKey: "theme_jobs", words: [
    "word_teacher", "word_doctor", "word_police", "word_firefighter", "word_builder",
    "word_driver", "word_chef", "word_waiter", "word_hairdresser", "word_artist",
    "word_musician", "word_singer", "word_actor", "word_writer", "word_programmer",
    "word_engineer", "word_accountant", "word_lawyer", "word_judge", "word_farmer",
    "word_pilot", "word_sailor", "word_soldier", "word_janitor", "word_cashier",
    "word_seller", "word_electrician", "word_plumber", "word_mechanic", "word_photographer",
    "word_designer", "word_journalist", "word_blogger", "word_courier", "word_taxi_driver",
    "word_nurse", "word_dentist", "word_vet", "word_president", "word_businessman"
])

let transportTheme = Theme(nameKey: "theme_transport", words: [
    "word_car", "word_bus", "word_tram", "word_trolleybus", "word_metro",
    "word_train", "word_airplane", "word_helicopter", "word_ship", "word_boat",
    "word_yacht", "word_motorboat", "word_submarine", "word_bicycle", "word_motorcycle",
    "word_scooter", "word_kick_scooter", "word_taxi", "word_truck", "word_tank",
    "word_tractor", "word_excavator", "word_bulldozer", "word_fire_truck", "word_ambulance",
    "word_police_car", "word_elevator", "word_escalator", "word_carriage", "word_sled",
    "word_carousel", "word_ferris_wheel", "word_sailboat", "word_catamaran", "word_van",
    "word_limo", "word_pickup", "word_suv", "word_rocket", "word_drone"
])

let moviesTheme = Theme(nameKey: "theme_movies", words: [
    "word_titanic", "word_avatar", "word_matrix", "word_harry_potter", "word_shrek",
    "word_terminator", "word_star_wars", "word_lotr", "word_pirates", "word_gladiator",
    "word_joker", "word_batman", "word_spiderman", "word_iron_man", "word_avengers",
    "word_lion_king", "word_frozen", "word_cars", "word_toy_story", "word_winnie_pooh",
    "word_cheburashka", "word_masha_bear", "word_bremen", "word_prostokvashino", "word_nu_pogodi",
    "word_aladdin", "word_mermaid", "word_garfield", "word_puss_boots", "word_diamond_arm",
    "word_caucasian_captive", "word_ivan_vasilievich", "word_irony_of_fate", "word_home_alone",
    "word_zootopia", "word_walle", "word_sherlock_holmes", "word_indiana_jones",
    "word_jurassic_park", "word_gentlemen_of_fortune"
])

let travelTheme = Theme(nameKey: "theme_travel", words: [
    "word_passport", "word_visa", "word_airport", "word_suitcase", "word_backpack",
    "word_ticket", "word_hotel", "word_hostel", "word_map", "word_beach",
    "word_sea", "word_mountain", "word_forest", "word_museum", "word_park",
    "word_excursion", "word_guide", "word_souvenir", "word_camera", "word_compass",
    "word_guidebook", "word_resort", "word_cruise", "word_tent", "word_hike",
    "word_campfire", "word_sunglasses", "word_sunscreen", "word_swimsuit", "word_flip_flops",
    "word_swimming_pool", "word_landmark", "word_currency", "word_sim_card", "word_language",
    "word_border", "word_postcard", "word_luggage", "word_check_in", "word_vacation"
])

let sportsTheme = Theme(nameKey: "theme_sports", words: [
    "word_football", "word_basketball", "word_volleyball", "word_tennis", "word_hockey",
    "word_boxing", "word_swimming", "word_running", "word_skiing", "word_snowboarding",
    "word_figure_skating", "word_gymnastics", "word_yoga", "word_fitness", "word_bodybuilding",
    "word_chess", "word_checkers", "word_billiards", "word_bowling", "word_darts",
    "word_surfing", "word_diving", "word_skydiving", "word_climbing", "word_cycling",
    "word_rollerskates", "word_skateboard", "word_karate", "word_judo", "word_taekwondo",
    "word_wrestling", "word_kickboxing", "word_mma", "word_golf", "word_cricket",
    "word_rugby", "word_badminton", "word_ping_pong", "word_curling", "word_olympics"
])

let celebritiesTheme = Theme(nameKey: "theme_celebrities", words: [
    "word_elon_musk", "word_bill_gates", "word_steve_jobs", "word_mark_zuckerberg", "word_donald_trump",
    "word_barack_obama", "word_vladimir_putin", "word_messi", "word_ronaldo", "word_lebron",
    "word_jordan", "word_tyson", "word_mcgregor", "word_khabib", "word_beyonce",
    "word_rihanna", "word_lady_gaga", "word_taylor_swift", "word_eminem", "word_drake",
    "word_kanye", "word_michael_jackson", "word_madonna", "word_britney_spears", "word_dicaprio",
    "word_brad_pitt", "word_angelina_jolie", "word_tom_cruise", "word_tom_hanks", "word_morgan_freeman",
    "word_downey_jr", "word_dwayne_johnson", "word_will_smith", "word_johnny_depp", "word_keanu_reeves",
    "word_jlo", "word_scarlett_johansson", "word_emma_watson", "word_oprah", "word_einstein"
])

let countriesTheme = Theme(nameKey: "theme_countries", words: [
    "word_russia", "word_usa", "word_china", "word_japan", "word_germany",
    "word_france", "word_italy", "word_spain", "word_england", "word_turkey",
    "word_egypt", "word_india", "word_brazil", "word_argentina", "word_mexico",
    "word_canada", "word_australia", "word_norway", "word_sweden", "word_finland",
    "word_poland", "word_ukraine", "word_belarus", "word_kazakhstan", "word_kyrgyzstan",
    "word_uzbekistan", "word_tajikistan", "word_georgia", "word_armenia", "word_azerbaijan",
    "word_iran", "word_iraq", "word_saudi_arabia", "word_uae", "word_israel",
    "word_greece", "word_portugal", "word_netherlands", "word_belgium", "word_switzerland"
])

let tvShowsTheme = Theme(nameKey: "theme_tv_shows", words: [
    "word_game_of_thrones", "word_friends", "word_simpsons", "word_dr_house", "word_sherlock",
    "word_stranger_things", "word_breaking_bad", "word_better_call_saul", "word_peaky_blinders", "word_the_crown",
    "word_black_mirror", "word_vikings", "word_squid_game", "word_mandalorian", "word_star_trek",
    "word_dexter", "word_walking_dead", "word_house_of_cards", "word_supernatural", "word_dr_who",
    "word_south_park", "word_family_guy", "word_emily_in_paris", "word_sex_and_the_city", "word_bridgerton",
    "word_downton_abbey", "word_big_little_lies", "word_watchmen", "word_loki", "word_wandavision",
    "word_univer", "word_interny", "word_papiny_dochki", "word_kuhnya", "word_realniye_patsani",
    "word_slovo_patsana", "word_gluhar", "word_sled_show", "word_molodyozhka", "word_rublevka_cop"
])

let musicTheme = Theme(nameKey: "theme_music", words: [
    "word_rock", "word_pop", "word_jazz", "word_blues", "word_rap",
    "word_hip_hop", "word_techno", "word_rave", "word_disco_music", "word_country_music",
    "word_classical", "word_opera", "word_chanson", "word_folk", "word_guitar",
    "word_piano", "word_drums", "word_violin", "word_saxophone", "word_flute",
    "word_trumpet", "word_microphone", "word_speaker", "word_headphones", "word_concert",
    "word_album", "word_song", "word_music_video", "word_festival", "word_orchestra",
    "word_choir", "word_conductor", "word_notes", "word_melody", "word_rhythm",
    "word_beat", "word_dj", "word_karaoke", "word_ringtone", "word_beatles"
])

let adultsThemes: [Theme] = [
    Theme(nameKey: "theme_adult", words: [
        "word_date", "word_kiss", "word_flirt", "word_wedding", "word_honeymoon",
        "word_sex", "word_condom", "word_orgasm", "word_erotica", "word_passion",
        "word_seduction", "word_caress", "word_hug", "word_romance", "word_lover",
        "word_cheating", "word_jealousy", "word_naked", "word_lingerie", "word_stockings",
        "word_lace", "word_lipstick", "word_perfume", "word_silk", "word_bath",
        "word_candles", "word_champagne", "word_oysters", "word_strawberry", "word_massage",
        "word_negligee", "word_bikini", "word_dance", "word_striptease", "word_coquetry",
        "word_party", "word_bar", "word_nightclub", "word_casino", "word_tattoo"
    ])
]

let allThemes: [Theme] = [
    foodTheme,
    animalsTheme,
    jobsTheme,
    transportTheme,
    moviesTheme,
    travelTheme,
    sportsTheme,
    celebritiesTheme,
    countriesTheme,
    tvShowsTheme,
    musicTheme
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
