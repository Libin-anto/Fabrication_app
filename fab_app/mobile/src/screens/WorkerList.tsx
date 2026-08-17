import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { Feather } from '@expo/vector-icons';
import { getWorkers, deleteWorker, getCurrentAssignments } from '../services/api';
import SearchBar from '../components/SearchBar';
import { useExitAppOnBack } from '../hooks/useExitAppOnBack';

export default function WorkerList({ navigation }: any) {
  const [workers, setWorkers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useExitAppOnBack();
  const [error, setError] = useState<string | null>(null);
  const [confirmDeleteId, setConfirmDeleteId] = useState<number | null>(null);

  const fetchWorkers = async () => {
    try {
      setLoading(true);
      setError(null);
      const [data, assignmentsData] = await Promise.all([
        getWorkers(),
        getCurrentAssignments()
      ]);
      const assignmentMap = new Map();
      assignmentsData.forEach((a: any) => {
        assignmentMap.set(a.worker_id, a.machine_name);
      });
      const combined = data.map((w: any) => ({
        ...w,
        assigned_machine: assignmentMap.get(w.id) || null
      }));
      setWorkers(combined);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch workers');
    } finally {
      setLoading(false);
    }
  };
  
  useFocusEffect(
    useCallback(() => {
      fetchWorkers();
      setConfirmDeleteId(null);
    }, [])
  );

  const handleDelete = async (id: number) => {
    try {
      await deleteWorker(id);
      setConfirmDeleteId(null);
      fetchWorkers();
    } catch (err: any) {
      setError(err.message || 'Failed to delete worker');
    }
  };

  const handleSearch = (query: string) => {
    navigation.navigate('SearchResults', { query });
  };

  const renderWorker = ({ item }: { item: any }) => (
    <View style={[styles.card, !item.is_active && styles.cardInactive]}>
      {confirmDeleteId === item.id ? (
        <View style={styles.confirmContainer}>
          <Text style={styles.confirmText}>Remove {item.name}?</Text>
          <View style={styles.confirmActions}>
            <TouchableOpacity onPress={() => handleDelete(item.id)}>
              <Text style={styles.confirmYes}>YES</Text>
            </TouchableOpacity>
            <Text style={styles.confirmDivider}> / </Text>
            <TouchableOpacity onPress={() => setConfirmDeleteId(null)}>
              <Text style={styles.confirmNo}>NO</Text>
            </TouchableOpacity>
          </View>
        </View>
      ) : (
        <TouchableOpacity 
          style={styles.cardContent}
          onPress={() => navigation.navigate('WorkerForm', { worker: item })}
        >
          <View style={styles.cardIconContainer}>
            <Feather name="user" size={20} color="#3A322B" />
          </View>
          <View style={styles.cardDetailsMain}>
            <View style={styles.cardHeader}>
              <Text style={styles.workerName}>{item.name}</Text>
              <View style={styles.statusBadge}>
                <View style={[
                  styles.statusDot, 
                  !item.is_active && styles.statusDotInactive,
                  item.assigned_machine && styles.statusDotAssigned
                ]} />
                <Text style={[
                  styles.statusBadgeText, 
                  !item.is_active && styles.statusBadgeTextInactive,
                  item.assigned_machine && styles.statusBadgeTextAssigned
                ]}>
                  {item.assigned_machine ? 'Assigned' : (item.is_active ? 'Active' : 'Inactive')}
                </Text>
              </View>
            </View>
            <View style={styles.cardDetails}>
              <Text style={styles.detailText}>ID: {item.worker_id}</Text>
              <Text style={styles.detailText}>Role: {item.role}</Text>
              {item.assigned_machine && (
                <Text style={styles.detailText}>Tool: {item.assigned_machine}</Text>
              )}
            </View>
          </View>
        </TouchableOpacity>
      )}
      
      {item.is_active && confirmDeleteId !== item.id && (
        <TouchableOpacity 
          style={styles.deleteIconContainer}
          onPress={() => setConfirmDeleteId(item.id)}
        >
          <Feather name="x" size={20} color="#8C7F72" />
        </TouchableOpacity>
      )}
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Text style={styles.sectionHeader}>Workers</Text>
        </View>
        <TouchableOpacity 
          style={styles.addButton}
          onPress={() => navigation?.navigate('WorkerForm')}
        >
          <Feather name="plus" size={20} color="#C25B6E" />
        </TouchableOpacity>
      </View>

      <View style={styles.searchContainer}>
        <SearchBar onSearch={handleSearch} />
      </View>

      {error && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      )}

      {loading && workers.length === 0 ? (
        <View style={styles.centerAll}>
          <ActivityIndicator size="large" color="#D98CA0" />
        </View>
      ) : (
        <FlatList
          data={workers}
          keyExtractor={item => item.id.toString()}
          renderItem={renderWorker}
          contentContainerStyle={styles.listContent}
          ListEmptyComponent={
            <View style={styles.emptyState}>
              <Text style={styles.emptyStateText}>No workers found</Text>
            </View>
          }
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  centerAll: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 24,
    paddingBottom: 16,
  },
  headerLeft: {
    flexDirection: 'column',
  },
  sectionHeader: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 24,
  },
  addButton: {
    backgroundColor: '#D98CA0',
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
  },
  searchContainer: {
    paddingHorizontal: 24,
  },
  listContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    flexGrow: 1,
  },
  card: {
    backgroundColor: '#FFFCF8',
    marginBottom: 12,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    flexDirection: 'row',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  cardInactive: {
    opacity: 0.7,
  },
  cardContent: {
    padding: 16,
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  cardIconContainer: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#EFE6D8',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  cardDetailsMain: {
    flex: 1,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  workerName: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 16,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#D98CA0',
    marginRight: 6,
  },
  statusDotInactive: {
    backgroundColor: '#8C7F72',
  },
  statusDotAssigned: {
    backgroundColor: '#D98CA0',
  },
  statusBadgeText: {
    fontFamily: 'Inter_500Medium',
    color: '#3A322B',
    fontSize: 12,
  },
  statusBadgeTextInactive: {
    color: '#8C7F72',
  },
  statusBadgeTextAssigned: {
    color: '#D98CA0',
  },
  cardDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  detailText: {
    fontFamily: 'IBMPlexMono_400Regular',
    color: '#8C7F72',
    fontSize: 12,
  },
  deleteIconContainer: {
    padding: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  confirmContainer: {
    padding: 16,
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  confirmText: {
    fontFamily: 'Inter_500Medium',
    color: '#3A322B',
    fontSize: 14,
  },
  confirmActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  confirmYes: {
    fontFamily: 'Inter_700Bold',
    color: '#B94A4A',
    fontSize: 14,
  },
  confirmNo: {
    fontFamily: 'Inter_700Bold',
    color: '#8C7F72',
    fontSize: 14,
  },
  confirmDivider: {
    color: '#EDE1D3',
    fontSize: 14,
    marginHorizontal: 8,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 40,
  },
  emptyStateText: {
    fontFamily: 'Inter_400Regular',
    color: '#8C7F72',
    fontSize: 16,
  },
  errorContainer: {
    paddingHorizontal: 24,
    paddingBottom: 16,
    alignItems: 'center',
  },
  errorText: {
    fontFamily: 'Inter_400Regular',
    color: '#B94A4A',
    fontSize: 14,
    textAlign: 'center',
  },
});
