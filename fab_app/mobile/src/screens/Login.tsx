import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  ActivityIndicator
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import PressableScale from '../components/PressableScale';

export default function Login({ navigation }: any) {
  const [adminId, setAdminId] = useState('');
  const [accessCode, setAccessCode] = useState('');
  const handleLogin = () => {
    navigation.navigate('Main');
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        {/* Top Nameplate */}
        <View style={styles.headerContainer}>
          <View style={styles.nameplate}>
            <Text style={styles.nameplateText}>Fabrication Tool{'\n'}& Machine Management</Text>
          </View>
        </View>

        {/* Center Panel */}
        <View style={styles.formPanel}>
          <Text style={styles.formLabel}>Sign in</Text>

          <TextInput
            style={styles.input}
            placeholder="Admin ID"
            placeholderTextColor="#8C7F72"
            value={adminId}
            onChangeText={setAdminId}
            autoCapitalize="none"
          />

          <TextInput
            style={styles.input}
            placeholder="Access code"
            placeholderTextColor="#8C7F72"
            value={accessCode}
            onChangeText={setAccessCode}
            secureTextEntry
          />

          <PressableScale
            style={styles.button}
            onPress={handleLogin}
          >
            <Text style={styles.buttonText}>Enter System</Text>
          </PressableScale>
        </View>

        {/* Bottom Status */}
        <View style={styles.footerContainer}>
          <Text style={styles.statusText}>System status: Ready</Text>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  centerAll: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  keyboardView: {
    flex: 1,
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    paddingVertical: 32,
  },
  headerContainer: {
    alignItems: 'center',
    marginTop: 20,
  },
  nameplate: {
    borderWidth: 1,
    borderColor: '#EDE1D3',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 14,
  },
  nameplateText: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 20,
    textAlign: 'center',
  },
  formPanel: {
    backgroundColor: '#FFFCF8',
    padding: 24,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    borderRadius: 14,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 5,
    elevation: 8,
  },
  formLabel: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 18,
    marginBottom: 20,
  },
  input: {
    backgroundColor: '#F7F0E7',
    borderWidth: 1,
    borderColor: '#EDE1D3',
    color: '#3A322B',
    fontFamily: 'Inter_400Regular',
    fontSize: 16,
    paddingHorizontal: 16,
    paddingVertical: 12,
    marginBottom: 16,
    borderRadius: 14,
  },
  button: {
    backgroundColor: '#D98CA0',
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 14,
    marginTop: 8,
  },
  buttonText: {
    fontFamily: 'Inter_700Bold',
    color: '#C25B6E',
    fontSize: 15,
  },
  footerContainer: {
    alignItems: 'center',
    marginBottom: 10,
  },
  statusText: {
    fontFamily: 'IBMPlexMono_400Regular',
    color: '#8C7F72',
    fontSize: 12,
  },
});
