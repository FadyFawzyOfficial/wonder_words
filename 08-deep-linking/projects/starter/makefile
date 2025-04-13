PACKAGES := $(wildcard packages/*)
FEATURES := $(wildcard packages/features/*)
BUILD-RUNNER := packages/fav_qs_api packages/key_value_storage

print:
	for feature in $(FEATURES); do \
		echo $${feature} ; \
	done
	for package in $(PACKAGES); do \
		echo $${package} ; \
	done

pods-clean:
	rm -Rf ios/Pods ; \
	rm -Rf ios/.symlinks ; \
	rm -Rf ios/Flutter/Flutter.framework ; \
	rm -Rf ios/Flutter/Flutter.podspec ; \
	rm ios/Podfile ; \
	rm ios/Podfile.lock ; \

git-clean:
	for feature in $(FEATURES); do \
		cd $${feature} ; \
		echo "Remove git cached folders & files in $${feature}" ; \
		git rm -r --cached .dart_tool/ ; \
		git rm -r --cached pubspec.lock ; \
		git rm -r --cached .flutter-plugins ; \
		git rm -r --cached .flutter-plugins-dependencies ; \
		cd ../../../ ; \
	done
	for package in $(PACKAGES); do \
		cd $${package} ; \
		echo "Updating dependencies on $${package}" ; \
		git rm -r --cached .dart_tool/ ; \
		git rm -r --cached pubspec.lock ; \
		git rm -r --cached .flutter-plugins ; \
		git rm -r --cached .flutter-plugins-dependencies ; \
		cd ../../ ; \
	done


get:
	flutter pub get
	for feature in $(FEATURES); do \
		cd $${feature} ; \
		echo "Updating dependencies on $${feature}" ; \
		flutter pub get ; \
		cd ../../../ ; \
	done
	for package in $(PACKAGES); do \
		cd $${package} ; \
		echo "Updating dependencies on $${package}" ; \
		flutter pub get ; \
		cd ../../ ; \
	done

upgrade:
	flutter pub upgrade
	for feature in $(FEATURES); do \
		cd $${feature} ; \
		echo "Updating dependencies on $${feature}" ; \
		flutter pub upgrade ; \
		cd ../../../ ; \
	done
	for package in $(PACKAGES); do \
		cd $${package} ; \
		echo "Updating dependencies on $${package}" ; \
		flutter pub upgrade ; \
		cd ../../ ; \
	done

lint:
	flutter analyze

format:
	flutter format --set-exit-if-changed .

testing:
	flutter test
	for feature in $(FEATURES); do \
		cd $${feature} ; \
		echo "Running test on $${feature}" ; \
		flutter test ; \
		cd ../../../ ; \
	done
	for package in $(PACKAGES); do \
		cd $${package} ; \
		echo "Running test on $${package}" ; \
		flutter test ; \
		cd ../../ ; \
	done

test-coverage:
	flutter test --coverage
	for feature in $(FEATURES); do \
		cd $${feature} ; \
		echo "Running test on $${feature}" ; \
		flutter test --coverage ; \
		cd ../../../ ; \
	done
	for package in $(PACKAGES); do \
		cd $${package} ; \
		echo "Running test on $${package}" ; \
		flutter test --coverage ; \
		cd ../../ ; \
	done

clean:
	flutter clean
	for feature in $(FEATURES); do \
		cd $${feature} ; \
		echo "Running clean on $${feature}" ; \
		flutter clean ; \
		cd ../../../ ; \
	done
	for package in $(PACKAGES); do \
		cd $${package} ; \
		echo "Running clean on $${package}" ; \
		flutter clean ; \
		cd ../../ ; \
	done

build-runner:
	for package in $(BUILD-RUNNER); do \
		cd $${package} ; \
		echo "Running build-runner on $${package}" ; \
		flutter pub run build_runner build --delete-conflicting-outputs ; \
		cd ../../ ; \
	done

patch-for-current-flutter:
	make patch-main
	make patch-searchbar
	make patch-package-intl
	make patch-package-share-plus
	make patch-package-svg
	make patch-package-secure-storage
	make patch-package-infinite-scroll
	make patch-monitoring
	make patch-gradle
	make patch-android-gradle
	make patch-kotlin
	make patch-android-app-compile

patch-main:
	sed -i '' -e 's/late final _favQsApi/late final FavQsApi _favQsApi/' lib/main.dart
	sed -i '' -e 's/late final _userRepository/late final UserRepository _userRepository/' lib/main.dart
	sed -i '' -e 's/late final _routerDelegate/late final RoutemasterDelegate _routerDelegate/' lib/main.dart

patch-searchbar:
	sed -i '' -e 's/SearchBar/AppSearchBar/g' packages/component_library/lib/src/search_bar.dart
	sed -i '' -e 's/SearchBar/AppSearchBar/g' integration_test/app_test.dart
	sed -i '' -e 's/child: SearchBar/child: AppSearchBar/' packages/features/quote_list/lib/src/quote_list_screen.dart

patch-package-intl:
	sed -i '' -e 's/intl: ^0.17.0/intl: any/' packages/component_library/pubspec.yaml
	sed -i '' -e 's/intl: ^0.17.0/intl: any/' packages/features/profile_menu/pubspec.yaml

patch-package-share-plus:
	sed -i '' -e 's/share_plus: ^4.0.10/share_plus: ^10.1.4/' packages/features/quote_details/pubspec.yaml

patch-package-svg:
	sed -i '' -e 's/flutter_svg: ^0.22.0/flutter_svg: ^2.0.17/' packages/component_library/pubspec.yaml

patch-package-secure-storage:
	sed -i '' -e 's/flutter_secure_storage: ^4.2.0/flutter_secure_storage: ^9.2.4/' packages/user_repository/pubspec.yaml

patch-package-infinite-scroll:
	sed -i '' -e 's/infinite_scroll_pagination: ^4.0.0-dev.1/infinite_scroll_pagination: ^4.0.0/' packages/features/quote_list/pubspec.yaml

patch-monitoring:
	sed -i '' -e 's/firebase_core: ^1.19.1/firebase_core: ^3.10.1/' packages/monitoring/pubspec.yaml
	sed -i '' -e 's/firebase_crashlytics: ^2.8.4/firebase_crashlytics: ^4.3.1/' packages/monitoring/pubspec.yaml
	sed -i '' -e 's/firebase_dynamic_links: ^4.3.1/firebase_dynamic_links: ^6.1.1/' packages/monitoring/pubspec.yaml
	sed -i '' -e 's/firebase_analytics: ^9.1.12/firebase_analytics: ^11.4.1/' packages/monitoring/pubspec.yaml
	sed -i '' -e 's/firebase_remote_config: ^2.0.11/firebase_remote_config: ^5.3.1/' packages/monitoring/pubspec.yaml

patch-gradle:
	sed -i '' -e 's/gradle-6.7-all.zip/gradle-8.10.2-all.zip/' android/gradle/wrapper/gradle-wrapper.properties
	sed -i '' -e 's/gradle-7.4-all.zip/gradle-8.10.2-all.zip/' packages/component_library/example/android/gradle/wrapper/gradle-wrapper.properties

patch-android-gradle:
	sed -i '' -e 's/gradle:4.1.0/gradle:8.8.2/' android/build.gradle
	sed -i '' -e 's/gradle:7.2.1/gradle:8.8.2/' packages/component_library/example/android/build.gradle
	sed -i '' -e 's/google-services:4.3.10/google-services:4.4.2/' android/build.gradle
	sed -i '' -e 's/firebase-crashlytics-gradle:2.7.1/firebase-crashlytics-gradle:3.0.1/' android/build.gradle

patch-kotlin:
	sed -i '' -e "s/ext.kotlin_version = '1.6.10'/ext.kotlin_version = '2.0.20'/" android/build.gradle
	sed -i '' -e "s/ext.kotlin_version = '1.6.10'/ext.kotlin_version = '2.0.20'/" packages/component_library/example/android/build.gradle

patch-android-app-compile:
	sed -i '' -e 's/compileSdkVersion 31/compileSdkVersion flutter.compileSdkVersion/' android/app/build.gradle
	sed -i '' -e 's/targetSdkVersion 30/targetSdkVersion flutter.targetSdkVersion/' android/app/build.gradle
