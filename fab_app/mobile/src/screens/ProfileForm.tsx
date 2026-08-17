import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  ActivityIndicator
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import PressableScale from '../components/PressableScale';
import { getMyProfile, updateMyProfile, setAuthToken } from '../services/api';
import { Feather } from '@expo/vector-icons';

export default function ProfileForm({ navigation }: any) {
  const [name, setName] = useState('');
  const [role, setRole] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const data = await getMyProfile();
        setName(data.name || '');
        setRole(data.role || '');
      } catch (err: any) {
        setError('Failed to load profile');
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    setSuccess(false);
    
    try {
      await updateMyProfile({
        name: name,
        role: role
      });
      setSuccess(true);
      setTimeout(() => {
        setSuccess(false);
      }, 2000);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  const handleLogout = () => {
    setAuthToken(null);
    navigation.reset({
      index: 0,
      routes: [{ name: 'Login' }],
    });
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <PressableScale onPress={() => navigation.goBack()} style={styles.backButton}>
          <Text style={styles.backText}>← Back</Text>
        </PressableScale>
        <Text style={styles.headerTitle}>My Profile</Text>
        <PressableScale onPress={handleLogout} style={styles.logoutButton}>
          <Feather name="log-out" size={20} color="#B94A4A" />
        </PressableScale>
      </View>

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <View style={styles.formPanel}>
          <Text style={styles.formLabel}>Admin Details</Text>
          
          {loading ? (
            <ActivityIndicator color="#C25B6E" />
          ) : (
            <>
              {error && (
                <View style={styles.errorBanner}>
                  <Text style={styles.errorText}>{error}</Text>
                </View>
              )}

              {success && (
                <View style={styles.successBanner}>
                  <Text style={styles.successText}>Profile updated successfully!</Text>
                </View>
              )}

              <TextInput
                style={styles.input}
                placeholder="Full Name"
                placeholderTextColor="#8C7F72"
                value={name}
                onChangeText={setName}
              />

              <TextInput
                style={styles.input}
                placeholder="Role / Title"
                placeholderTextColor="#8C7F72"
                value={role}
                onChangeText={setRole}
              />

              <PressableScale
                style={styles.button}
                onPress={handleSave}
                disabled={saving}
              >
                {saving ? (
                  <ActivityIndicator color="#C25B6E" />
                ) : (
                  <Text style={styles.buttonText}>Save Profile</Text>
                )}
              </PressableScale>
            </>
          )}
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F7F0E7' },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 20,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#EDE1D3',
  },
  backButton: {
    padding: 8,
    marginRight: 16,
  },
  backText: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 16,
  },
  headerTitle: {
    fontFamily: 'Inter_700Bold',
    fontSize: 20,
    color: '#3A322B',
    flex: 1,
    textAlign: 'center',
  },
  logoutButton: {
    padding: 8,
    marginLeft: 16,
  },
  keyboardView: { flex: 1, paddingHorizontal: 24, paddingTop: 32 },
  formPanel: { backgroundColor: '#FFFCF8', padding: 24, borderWidth: 1, borderColor: '#EDE1D3', borderRadius: 14, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.08, shadowRadius: 5, elevation: 8 },
  formLabel: { fontFamily: 'Inter_700Bold', color: '#3A322B', fontSize: 18, marginBottom: 20 },
  input: { backgroundColor: '#F7F0E7', borderWidth: 1, borderColor: '#EDE1D3', color: '#3A322B', fontFamily: 'Inter_400Regular', fontSize: 16, paddingHorizontal: 16, paddingVertical: 12, marginBottom: 16, borderRadius: 14 },
  button: { backgroundColor: '#D98CA0', paddingVertical: 12, alignItems: 'center', borderRadius: 14, marginTop: 8 },
  buttonText: { fontFamily: 'Inter_700Bold', color: '#C25B6E', fontSize: 15 },
  errorBanner: { backgroundColor: '#FEE2E2', padding: 12, borderRadius: 8, marginBottom: 16, borderWidth: 1, borderColor: '#FCA5A5' },
  errorText: { color: '#991B1B', fontFamily: 'Inter_500Medium', fontSize: 14, textAlign: 'center' },
  successBanner: { backgroundColor: '#D1FAE5', padding: 12, borderRadius: 8, marginBottom: 16, borderWidth: 1, borderColor: '#6EE7B7' },
  successText: { color: '#065F46', fontFamily: 'Inter_500Medium', fontSize: 14, textAlign: 'center' },
});
