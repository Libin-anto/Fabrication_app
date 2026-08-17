import { useCallback } from 'react';
import { BackHandler, Alert } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';

export function useExitAppOnBack() {
  useFocusEffect(
    useCallback(() => {
      const onBackPress = () => {
        Alert.alert('Exit App', 'Are you sure you want to exit?', [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Yes', onPress: () => BackHandler.exitApp() },
        ]);
        return true;
      };

      const subscription = BackHandler.addEventListener('hardwareBackPress', onBackPress);

      return () => subscription.remove();
    }, [])
  );
}
