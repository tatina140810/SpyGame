//struct Theme {
//    let name: String
//    let words: [String]
//}

struct Theme {
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

let surrealTheme = Theme(nameKey: "theme_surreal", words: [
    "word_dream_maze", "word_crispy_dawn", "word_dancing_cloud", "word_orange_silence", "word_metal_sparrow",
    "word_talking_suitcase", "word_inverted_reality", "word_floating_stairs", "word_creaky_memory", "word_teapot_of_time",
    "word_moon_fridge", "word_whispering_sidewalk", "word_forgotten_symphony", "word_sand_glasses", "word_marble_cloud",
    "word_crystal_alarm", "word_folding_sky", "word_dancing_lamp_skeleton", "word_memory_whirlwind", "word_dream_telescope",
    "word_stairless_ladder", "word_singing_stone", "word_thought_fan", "word_closed_rainbow", "word_electric_bush",
    "word_mirror_no_reflection", "word_pollen_of_past", "word_sticky_noon", "word_sighing_chair", "word_cookie_with_secret",
    "word_conversation_in_glass", "word_shoes_without_feet", "word_thunder_in_pocket", "word_memory_ball", "word_slippery_calendar",
    "word_bridge_to_nowhere", "word_sniffing_tv", "word_rainbow_tear", "word_ceiling_door", "word_babbling_lamp",
    "word_fish_in_tree", "word_window_underwater", "word_fog_slippers", "word_laughing_wall", "word_letter_in_sand",
    "word_wind_puzzle", "word_paper_echo", "word_clock_no_hands", "word_star_under_table", "word_silent_bulb"
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
    surrealTheme,
] + adultsThemes
