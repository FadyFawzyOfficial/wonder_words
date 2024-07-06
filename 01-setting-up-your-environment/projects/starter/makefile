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
	patch-main \
	patch-searchbar \
	patch-package-intl \
	patch-package-infinite-scroll \
	patch-monitoring \
	patch-android-gradle \
	patch-android-app-compile

patch-main:
	sed -i 's/late final _favQsApi/late final FavQsApi _favQsApi/' lib/main.dart
	sed -i 's/late final _userRepository/late final UserRepository _userRepository/' lib/main.dart
	sed -i 's/late final _routerDelegate/late final RoutemasterDelegate _routerDelegate/' lib/main.dart

patch-searchbar:
	sed -i 's/SearchBar/AppSearchBar/g' packages/component_library/lib/src/search_bar.dart
	sed -i 's/child: SearchBar/child: AppSearchBar/' packages/features/quote_list/lib/src/quote_list_screen.dart

patch-package-intl:
	sed -i 's/intl: ^0.17.0/intl: ^0.18.1/' packages/component_library/pubspec.yaml
	sed -i 's/intl: ^0.17.0/intl: ^0.18.1/' packages/features/profile_menu/pubspec.yaml

patch-package-infinite-scroll:
	sed -i 's/infinite_scroll_pagination: ^4.0.0-dev.1/infinite_scroll_pagination: ^4.0.0/' packages/features/quote_list/pubspec.yaml

patch-monitoring:
	sed -i 's/firebase_core: ^1.19.1/firebase_core: ^2.17.0/' packages/monitoring/pubspec.yaml
	sed -i 's/firebase_crashlytics: ^2.8.4/firebase_crashlytics: ^3.3.7/' packages/monitoring/pubspec.yaml
	sed -i 's/firebase_dynamic_links: ^4.3.1/firebase_dynamic_links: ^5.3.7/' packages/monitoring/pubspec.yaml
	sed -i 's/firebase_analytics: ^9.1.12/firebase_analytics: ^10.5.1/' packages/monitoring/pubspec.yaml
	sed -i 's/firebase_remote_config: ^2.0.11/firebase_remote_config: ^4.2.7/' packages/monitoring/pubspec.yaml

patch-android-gradle:
	sed -i "s/classpath 'com.android.tools.build:gradle:4.1.0'/classpath 'com.android.tools.build:gradle:7.4.1'/" android/build.gradle
	sed -i "s/classpath 'com.google.gms:google-services:4.3.10'/classpath 'com.google.gms:google-services:4.3.14'/" android/build.gradle

patch-android-app-compile:
	sed -i 's/compileSdkVersion 31/compileSdkVersion 33/' android\app\build.gradle
