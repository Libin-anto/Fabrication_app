import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { getDashboardStats } from '../services/api';
import PressableScale from '../components/PressableScale';
import { Feather } from '@expo/vector-icons';

export default function Dashboard({ navigation }: any) {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useFocusEffect(
    useCallback(() => {
      const fetchStats = async () => {
        try {
          const data = await getDashboardStats();
          console.log(`[DIAGNOSTIC - ${new Date().toISOString()}] Dashboard fetchStats raw response:`, JSON.stringify(data));
          setStats(data);
        } catch (error) {
          console.error('Failed to fetch stats', error);
        } finally {
          setLoading(false);
        }
      };
      fetchStats();
    }, [])
  );
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.sectionHeader}>Facility Overview</Text>
        <PressableScale style={styles.profileButton} onPress={() => navigation.navigate('Profile')}>
          <Feather name="user" size={24} color="#8C7F72" />
        </PressableScale>
      </View>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        
        {loading || !stats ? (
          <View style={styles.statsLoadingContainer}>
            <ActivityIndicator size="large" color="#D98CA0" />
          </View>
        ) : (
          <>
            <View style={styles.gridContainer}>
              <View style={styles.statCard}>
                <Text style={styles.statNumber}>{stats.total_workers}</Text>
                <Text style={styles.statLabel}>WORKERS</Text>
              </View>
              <View style={styles.statCard}>
                <Text style={styles.statNumber}>{stats.total_machines}</Text>
                <Text style={styles.statLabel}>MACHINES</Text>
              </View>
              <View style={styles.statCard}>
                <Text style={styles.statNumber}>{stats.available}</Text>
                <Text style={styles.statLabel}>AVAILABLE</Text>
              </View>
              <View style={styles.statCard}>
                <Text style={styles.statNumber}>{stats.assigned}</Text>
                <Text style={styles.statLabel}>ASSIGNED</Text>
              </View>
            </View>

            <View style={[styles.fullCard, styles.accentException]}>
              <Text style={[styles.statNumber, styles.textException]}>{stats.under_repair}</Text>
              <Text style={[styles.statLabel, styles.textException]}>UNDER REPAIR</Text>
            </View>
          </>
        )}

      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  scrollContent: {
    padding: 24,
    paddingTop: 8,
    paddingBottom: 40,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 24,
    paddingBottom: 8,
  },
  profileButton: {
    padding: 8,
  },
  sectionHeader: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 24,
  },
  statsLoadingContainer: {
    paddingVertical: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  gridContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  statCard: {
    backgroundColor: '#FFFCF8',
    width: '48%',
    padding: 16,
    marginBottom: 16,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  fullCard: {
    backgroundColor: '#FFFCF8',
    width: '100%',
    padding: 16,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  accentException: {
    borderColor: '#B94A4A',
    backgroundColor: '#F5E3E1',
  },
  statNumber: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 32,
    marginBottom: 4,
  },
  textException: {
    color: '#B94A4A',
  },
  statLabel: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 12,
    letterSpacing: 1,
  },
});
