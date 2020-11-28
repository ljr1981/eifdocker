note
	description: "Application Main Window"

class
	ED_MAIN_WINDOW

inherit
	EV_TITLED_WINDOW
		redefine
			create_interface_objects,
			initialize,
			make_with_title
		end

	ED_ANY
		undefine
			default_create,
			copy
		end

create
	make_with_title

feature {NONE} -- Initialization

	make_with_title (a_title: like title)
			--<Precursor>
			-- and set preferences from conf file.
		note
			why_am_i_here: "[
				Placing the call to `set_menu_bar' in either the
				`create_interface_objects' or `initialize' causes
				the follow-on "ensure then" to fail in the
				`default_create' of {EV_WINDOW} (called by Precursor
				below). So, to handle this ensure properly, we
				must place the menu bar setting here so we do
				not violate the conract.
				
				is_in_default_state: is_in_default_state
				]"
		do
			initialize_preferences
			Precursor (a_title)
			set_menu_bar (create {ED_MAIN_MENU_BAR}.make (Current))
		end

	create_interface_objects
			--<Precursor>
		do
			Precursor
		end

	initialize
			--<Precursor>
		do
			Precursor
		end

feature {NONE} -- Initialization Support

	initialize_preferences
			-- Initialize the preferences of Current.
		note
			design: "[
				The most important line is the `log_info' call. Why?
				The log info call reaches out to get the `log_level'
				as set in the preferences and ensures it endures throughout
				the applications life.
				
				Otherwise—be sure to set up as many application-wide
				preferences as you need to at this level. You can read
				and utilize preferences at any time, but this is the
				place to initialize them!
				]"
		do
			if attached {INTEGER_PREFERENCE} prefs.get_preference ("debug.log_level") as al_log_level then
				set_log_level (al_log_level.value)
			end
			log_info (create {ANY}, "start_up") -- Logging startup ensure that the `logger'
												-- gets the right log_level.
		end

	set_padding_and_border (a_box: EV_BOX)
			-- Set common padding/border pixel for `a_box'.
		do
			a_box.set_padding (3)
			a_box.set_border_width (3)
		end

feature {ED_MAIN_MENU_BAR} -- Implementation: Prefs

	prefs: PREFERENCES
			-- The preferences for Current Application
		local
			l_storage: PREFERENCES_STORAGE_XML
				-- Factory & Manager(s)
			l_factory: GRAPHICAL_PREFERENCE_FACTORY		-- Factory to create Prefs for Mgrs
			l_manager: PREFERENCE_MANAGER				-- A Manager responsible for each pref domain

			l_log_level_pref: INTEGER_PREFERENCE
			l_path_pref: PATH_PREFERENCE
			l_log_pref: INTEGER_PREFERENCE
			l_arr_pref: ARRAY_PREFERENCE
			l_str_pref: STRING_PREFERENCE
		once
			create l_storage.make_with_location ("eifdocker.conf")
			create Result.make_with_defaults_and_storage (<<"defaults.conf">>, l_storage)
			create l_factory

--				-- Library
--			l_manager := prefs.new_manager ("library")

--				--library.name
--			l_str_pref := l_factory.new_string_preference_value (l_manager, "library.name", "")
--			Result.save_preference (l_str_pref)

				-- Debug
			l_manager := prefs.new_manager ("debug")

				--debug.log_level
			l_log_pref := l_factory.new_integer_preference_value (l_manager, "debug.log_level", 7)
			l_log_pref.set_description ("1 EMERG < 2 ALERT < 3 CRIT < 4 ERROR < 5 WARN < 6 NOTIC < 7 INFO < 8 DEBUG")
			Result.save_preference (l_log_pref)

--				-- Paths ...
--			l_manager := prefs.new_manager ("paths")

--				-- paths.vcpkg
--			l_vcpkg_pref := l_factory.new_path_preference_value (l_manager, "paths.wrapc_lib", create {PATH}.make_empty)
--			l_vcpkg_pref.set_description ("Set the full-path location of WrapC lib directory.")
--			Result.save_preference (l_vcpkg_pref)

--				-- paths.vcpkg
--			l_vcpkg_pref := l_factory.new_path_preference_value (l_manager, "paths.vcpkg", create {PATH}.make_empty)
--			l_vcpkg_pref.set_description ("Set the full-path location of Microsoft vcpkg.exe directory.")
--			Result.save_preference (l_vcpkg_pref)

--				-- paths.eiffel_studio
--			l_eif_pref := l_factory.new_path_preference_value (l_manager, "paths.eiffel_studio", create {PATH}.make_empty)
--			l_eif_pref.set_description ("Set the full-path location of Eiffel Software EiffelStudio directory in Program Files.")
--			Result.save_preference (l_eif_pref)

--				-- Files
--			l_manager := prefs.new_manager ("files")

--				-- files.libs
--			l_arr_pref := l_factory.new_array_preference_value (l_manager, "files.libs", <<"">>)
--			l_arr_pref.set_description ("A list of LIB files to move from vcpkg to wrap project.")
--			Result.save_preference (l_arr_pref)
--			l_path_pref := l_factory.new_path_preference_value (l_manager, "files.lib_path", create {PATH}.make_empty)
--			l_path_pref.set_description ("The target path to copy LIB files into.")
--			Result.save_preference (l_path_pref)
--			l_path_pref := l_factory.new_path_preference_value (l_manager, "files.lib_src_path", create {PATH}.make_empty)
--			l_path_pref.set_description ("An alternate source path for the list of LIB files.")
--			Result.save_preference (l_path_pref)

--				-- files.dlls
--			l_arr_pref := l_factory.new_array_preference_value (l_manager, "files.dlls", <<"">>)
--			l_arr_pref.set_description ("A list of DLL files to move from vcpkg to wrap project.")
--			Result.save_preference (l_arr_pref)
--			l_path_pref := l_factory.new_path_preference_value (l_manager, "files.dll_path", create {PATH}.make_empty)
--			l_path_pref.set_description ("The target path to copy DLL files into.")
--			Result.save_preference (l_path_pref)
--			l_path_pref := l_factory.new_path_preference_value (l_manager, "files.dll_src_path", create {PATH}.make_empty)
--			l_path_pref.set_description ("An alternate source path for the list of DLL files.")
--			Result.save_preference (l_path_pref)

			Result.set_save_defaults (True)
			Result.save_preferences
		end

	set_string_pref (a_name, a_pref: STRING)
			-- Sets a {STRING_PREFERENCE} of `a_name' to value of `a_pref'.
		note
			warning: "[
				If `a_name' does not exist, then this call silently fails.
				The stronger, but more dangerous version is to change the "if"
				to "check" which will break the software if it fails rather
				than silently swallowing an error.
				]"
		require
			has_pref: attached {STRING_PREFERENCE} prefs.get_preference (a_name)
		do
			check has_str_pref: attached {STRING_PREFERENCE} prefs.get_preference (a_name) as al_pref then
				al_pref.set_value (a_pref)
			end
		ensure
			set: attached {STRING_PREFERENCE} prefs.get_preference (a_name) as al_pref and then
					al_pref.value.same_string (a_pref)
		end

	set_path_pref (a_name: STRING; a_pref: PATH)
			-- Sets a {PATH_PREFERENCE} of `a_name' to value of `a_pref'.
		note
			warning: "[
				If `a_name' does not exist, then this call silently fails.
				The stronger, but more dangerous version is to change the "if"
				to "check" which will break the software if it fails rather
				than silently swallowing an error.
				]"
		require
			has_pref: attached {PATH_PREFERENCE} prefs.get_preference (a_name)
		do
			check has_path_pref: attached {PATH_PREFERENCE} prefs.get_preference (a_name) as al_pref then
				al_pref.set_value (a_pref)
			end
		ensure
			set: attached {PATH_PREFERENCE} prefs.get_preference (a_name) as al_pref and then
					al_pref.value ~ a_pref
		end


end
