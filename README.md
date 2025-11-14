# music_in_touch

Solomusicos Flutter app scaffold that centralizes musicians, announcements, and user collaboration experiences.

## Project Structure

```text
solomusicos_flutter/
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── test/
├── firebase/
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   ├── storage.rules
│   └── firebase.json
├── functions/
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       └── index.ts
├── assets/
│   ├── images/
│   │   ├── avatars/
│   │   ├── instruments/
│   │   ├── placeholders/
│   │   └── logos/
│   └── icons/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_fonts.dart
│   │   │   └── app_theme.dart
│   │   ├── constants/
│   │   │   ├── app_routes.dart
│   │   │   ├── app_sizes.dart
│   │   │   └── app_strings.dart
│   │   ├── widgets/
│   │   │   ├── sm_scaffold.dart
│   │   │   ├── sm_button.dart
│   │   │   ├── sm_text_field.dart
│   │   │   ├── sm_chip.dart
│   │   │   ├── section_title.dart
│   │   │   └── loading_indicator.dart
│   │   ├── services/
│   │   │   ├── firebase_initializer.dart
│   │   │   ├── analytics_service.dart
│   │   │   └── remote_config_service.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── debouncer.dart
│   │       └── formatters.dart
│   └── features/
│       ├── splash/
│       │   ├── presentation/
│       │   │   └── splash_page.dart
│       │   └── application/
│       │       └── splash_controller.dart
│       ├── auth/
│       │   ├── data/
│       │   │   ├── auth_repository.dart
│       │   │   └── auth_exceptions.dart
│       │   ├── domain/
│       │   │   └── user_entity.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   ├── login_page.dart
│       │       │   ├── register_page.dart
│       │       │   └── forgot_password_page.dart
│       │       └── widgets/
│       │           ├── login_form.dart
│       │           ├── register_form.dart
│       │           └── social_login_buttons.dart
│       ├── user_home/
│       │   ├── data/
│       │   │   ├── user_home_repository.dart
│       │   │   ├── musician_card_model.dart
│       │   │   ├── announcement_model.dart
│       │   │   └── instrument_category_model.dart
│       │   ├── controllers/
│       │   │   └── user_home_controller.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   └── user_home_page.dart
│       │       └── widgets/
│       │           ├── header/
│       │           │   ├── sm_app_bar.dart
│       │           │   ├── global_stats_row.dart
│       │           │   └── main_nav_bar.dart
│       │           ├── sidebar/
│       │           │   ├── user_sidebar.dart
│       │           │   ├── user_menu_list.dart
│       │           │   ├── location_selector.dart
│       │           │   ├── language_selector.dart
│       │           │   └── top_influences_list.dart
│       │           ├── profile/
│       │           │   ├── profile_status_bar.dart
│       │           │   ├── quick_actions_row.dart
│       │           │   └── profile_link_box.dart
│       │           ├── musicians/
│       │           │   ├── recommended_users_section.dart
│       │           │   ├── new_musicians_section.dart
│       │           │   ├── musicians_grid.dart
│       │           │   └── musicians_by_instrument_section.dart
│       │           ├── search/
│       │           │   ├── advanced_search_box.dart
│       │           │   ├── instrument_dropdown.dart
│       │           │   ├── style_dropdown.dart
│       │           │   ├── profile_type_dropdown.dart
│       │           │   ├── gender_radio_group.dart
│       │           │   ├── province_dropdown.dart
│       │           │   └── city_dropdown.dart
│       │           ├── announcements/
│       │           │   ├── new_announcements_section.dart
│       │           │   └── announcement_card.dart
│       │           └── footer/
│       │               ├── provinces_list_section.dart
│       │               └── bottom_cookie_bar.dart
│       ├── musicians/
│       │   ├── data/
│       │   │   └── musicians_repository.dart
│       │   ├── domain/
│       │   │   └── musician_entity.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   ├── musician_detail_page.dart
│       │       │   └── musician_search_page.dart
│       │       └── widgets/
│       │           ├── musician_card.dart
│       │           ├── musician_filter_panel.dart
│       │           └── musician_filters_chip_row.dart
│       ├── announcements/
│       │   ├── data/
│       │   │   └── announcements_repository.dart
│       │   ├── domain/
│       │   │   └── announcement_entity.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   ├── announcements_list_page.dart
│       │       │   ├── announcement_detail_page.dart
│       │       │   └── announcement_form_page.dart
│       │       └── widgets/
│       │           ├── announcement_card.dart
│       │           ├── announcement_filter_panel.dart
│       │           └── announcement_form.dart
│       ├── profile/
│       │   ├── data/
│       │   │   ├── profile_repository.dart
│       │   │   └── profile_dto.dart
│       │   ├── domain/
│       │   │   └── profile_entity.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   ├── profile_overview_page.dart
│       │       │   ├── profile_edit_page.dart
│       │       │   └── account_page.dart
│       │       └── widgets/
│       │           ├── profile_header.dart
│       │           ├── profile_form.dart
│       │           └── profile_stats_row.dart
│       ├── media/
│       │   ├── data/
│       │   │   └── media_repository.dart
│       │   ├── domain/
│       │   │   └── media_item.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   └── media_gallery_page.dart
│       │       └── widgets/
│       │           ├── media_grid.dart
│       │           ├── audio_player_widget.dart
│       │           └── video_player_widget.dart
│       ├── messaging/
│       │   ├── data/
│       │   │   ├── chat_repository.dart
│       │   │   └── message_dto.dart
│       │   ├── domain/
│       │   │   ├── chat_thread.dart
│       │   │   └── chat_message.dart
│       │   └── presentation/
│       │       ├── pages/
│       │       │   └── chat_page.dart
│       │       └── widgets/
│       │           ├── message_bubble.dart
│       │           └── chat_input_field.dart
│       └── settings/
│           ├── presentation/
│           │   ├── pages/
│           │   │   ├── settings_page.dart
│           │   │   └── help_page.dart
│           │   └── widgets/
│           │       └── settings_list.dart
│           └── application/
│               └── settings_controller.dart
├── pubspec.yaml
└── README.md
```

This layout bootstraps the core architectural areas (routing, features, services, Firebase, and assets) so new modules can be fleshed out quickly.
