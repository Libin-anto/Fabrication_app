import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { Feather } from '@expo/vector-icons';
import { getCurrentAssignments, returnAssignment, updateAssignmentLocation, getAssignmentHistory } from '../services/api';
import { formatDate } from '../services/formatDate';
import SearchBar from '../components/SearchBar';

export default function Activity({ navigation }: any) {
  const [activeTab, setActiveTab] = useState<'current' | 'history'>('current');
  const [searchQuery, setSearchQuery] = useState('');
  const [currentAssignments, setCurrentAssignments] = useState<any[]>([]);
  const [history, setHistory] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [currentLoaded, setCurrentLoaded] = useState(false);
  const [historyLoaded, setHistoryLoaded] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const fetchAssignments = async (forceRefetch = false) => {
    if (!forceRefetch && ((activeTab === 'current' && currentLoaded) || (activeTab === 'history' && historyLoaded))) {
      return;
    }

    try {
      setLoading(true);
      setError(null);
      if (activeTab === 'current') {
        const data = await getCurrentAssignments();
        setCurrentAssignments(data);
        setCurrentLoaded(true);
      } else {
        const data = await getAssignmentHistory();
        setHistory(data);
        setHistoryLoaded(true);
      }
    } catch (err: any) {
      setError(err.response?.data?.detail || err.message || 'Failed to fetch assignments');
    } finally {
      setLoading(false);
    }
  };

  useFocusEffect(
    useCallback(() => {
      let isActive = true;
      const fetchBothOnFocus = async () => {
        try {
          setLoading(true);
          setError(null);
          const [curData, histData] = await Promise.all([
            getCurrentAssignments(),
            getAssignmentHistory()
          ]);
          if (isActive) {
            setCurrentAssignments(curData);
            setHistory(histData);
            setCurrentLoaded(true);
            setHistoryLoaded(true);
          }
        } catch (err: any) {
          if (isActive) {
             setError(err.response?.data?.detail || err.message || 'Failed to fetch assignments');
          }
        } finally {
          if (isActive) setLoading(false);
        }
      };
      fetchBothOnFocus();
      return () => { isActive = false; };
    }, [])
  );

  useEffect(() => {
    fetchAssignments(false);
  }, [activeTab]);

  const handleReturn = async (id: number) => {
    try {
      setActionError(null);
      setCurrentAssignments(prev => prev.filter(a => a.id !== id));
      await returnAssignment(id);
      console.log(`[DIAGNOSTIC - ${new Date().toISOString()}] Activity returnAssignment resolved`);
      fetchAssignments(true);
    } catch (err: any) {
      setActionError(err.response?.data?.detail || err.message || 'Return failed');
      fetchAssignments();
    }
  };

  const handleLocationToggle = async (assignment: any) => {
    const newLocation = assignment.location === 'On Site' ? 'With Worker' : 'On Site';
    try {
      setActionError(null);
      setCurrentAssignments(prev => prev.map(a => 
        a.id === assignment.id ? { ...a, location: newLocation } : a
      ));
      await updateAssignmentLocation(assignment.id, newLocation);
    } catch (err: any) {
      setActionError(err.response?.data?.detail || err.message || 'Location update failed');
      fetchAssignments(true);
    }
  };

  const filteredCurrent = useMemo(() => {
    if (!searchQuery) return currentAssignments;
    const lowerQ = searchQuery.toLowerCase();
    return currentAssignments.filter(item => 
      item.worker_name?.toLowerCase().includes(lowerQ) ||
      item.machine_name?.toLowerCase().includes(lowerQ)
    );
  }, [currentAssignments, searchQuery]);

  const groupedHistory = useMemo(() => {
    let filtered = history;
    if (searchQuery) {
      const lowerQ = searchQuery.toLowerCase();
      filtered = history.filter(item => 
        item.worker_name?.toLowerCase().includes(lowerQ) ||
        item.machine_name?.toLowerCase().includes(lowerQ)
      );
    }
    const groups: { [key: string]: any[] } = {};
    filtered.forEach(item => {
      const key = item.worker_name || 'Unknown Worker';
      if (!groups[key]) {
        groups[key] = [];
      }
      groups[key].push(item);
    });
    return Object.keys(groups).map(workerName => ({
      workerName,
      data: groups[workerName]
    }));
  }, [history, searchQuery]);

  const renderCurrent = ({ item }: { item: any }) => (
    <View style={styles.card}>
      <View style={styles.cardHeader}>
        <View style={styles.cardHeaderLeft}>
          <Text style={styles.workerName}>{item.worker_name}</Text>
          <Text style={styles.machineName}>{item.machine_name}</Text>
        </View>
        <TouchableOpacity 
          style={[styles.locationBadge, item.location === 'With Worker' ? styles.locationBadgeWorker : styles.locationBadgeSite]}
          onPress={() => handleLocationToggle(item)}
        >
          <Text style={[styles.locationBadgeText, item.location === 'With Worker' && styles.locationBadgeTextWorker]}>
            {item.location ? item.location.toUpperCase() : 'ON SITE'}
          </Text>
        </TouchableOpacity>
      </View>
      <View style={styles.cardDetails}>
        <Text style={styles.detailText}>Assigned: {formatDate(item.assigned_at)}</Text>
        <TouchableOpacity 
          style={styles.returnButton}
          onPress={() => handleReturn(item.id)}
        >
          <Text style={styles.returnButtonText}>Return</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const renderHistoryGroup = ({ item }: { item: { workerName: string, data: any[] } }) => (
    <View style={styles.card}>
      <View style={styles.cardHeader}>
        <Text style={styles.workerName}>{item.workerName}</Text>
      </View>
      <View style={styles.cardDetailsHistory}>
        {item.data.map((histItem, index) => (
          <View key={histItem.id} style={[styles.historySubItem, index > 0 && styles.historySubItemBorder]}>
            <Text style={styles.machineNameHistory}>{histItem.machine_name}</Text>
            <View style={styles.timeBlockContainer}>
              <View style={styles.timeBlock}>
                <Text style={styles.timeLabel}>OUT:</Text>
                <Text style={styles.detailText}>{formatDate(histItem.assigned_at)}</Text>
              </View>
              <View style={styles.timeBlock}>
                <Text style={styles.timeLabel}>IN:</Text>
                <Text style={styles.detailText}>{formatDate(histItem.returned_at)}</Text>
              </View>
            </View>
          </View>
        ))}
      </View>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.sectionHeader}>Activity</Text>
      </View>

      <View style={styles.toggleContainer}>
        <View style={styles.toggleGroup}>
          <TouchableOpacity
            style={[styles.toggleButton, activeTab === 'current' && styles.toggleButtonActive]}
            onPress={() => setActiveTab('current')}
          >
            <Text style={[styles.toggleButtonText, activeTab === 'current' && styles.toggleButtonTextActive]}>
              Current
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.toggleButton, activeTab === 'history' && styles.toggleButtonActive]}
            onPress={() => setActiveTab('history')}
          >
            <Text style={[styles.toggleButtonText, activeTab === 'history' && styles.toggleButtonTextActive]}>
              History
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.searchContainer}>
        <SearchBar onSearch={setSearchQuery} />
      </View>

      {error && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={fetchAssignments}>
            <Text style={styles.retryButtonText}>Retry</Text>
          </TouchableOpacity>
        </View>
      )}

      {actionError && (
        <View style={styles.errorBanner}>
          <Text style={styles.errorBannerText}>{actionError}</Text>
        </View>
      )}

      {loading && !refreshing && ((activeTab === 'current' && currentAssignments.length === 0) || (activeTab === 'history' && history.length === 0)) ? (
        <View style={[styles.container, styles.centerAll]}>
          <ActivityIndicator size="large" color="#D98CA0" />
        </View>
      ) : (
        <FlatList
          data={activeTab === 'current' ? filteredCurrent : groupedHistory}
          keyExtractor={item => activeTab === 'current' ? item.id.toString() : item.workerName}
          renderItem={activeTab === 'current' ? renderCurrent : renderHistoryGroup}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={async () => {
                setRefreshing(true);
                await fetchAssignments(true);
                setRefreshing(false);
              }}
              tintColor="#D98CA0"
            />
          }
          ListEmptyComponent={
            !loading && !error ? (
              <View style={styles.emptyState}>
                <Text style={styles.emptyStateText}>
                  {activeTab === 'current' ? 'No active assignments' : 'No history found'}
                </Text>
              </View>
            ) : null
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
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    padding: 24,
    paddingBottom: 16,
  },
  sectionHeader: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 24,
    letterSpacing: 0,
  },
  toggleContainer: {
    paddingHorizontal: 24,
    marginBottom: 16,
  },
  searchContainer: {
    paddingHorizontal: 24,
  },
  toggleGroup: {
    flexDirection: 'row',
    backgroundColor: '#FFFCF8',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    overflow: 'hidden',
  },
  toggleButton: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
  },
  toggleButtonActive: {
    backgroundColor: '#D98CA0',
  },
  toggleButtonText: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 14,
  },
  toggleButtonTextActive: {
    color: '#C25B6E',
  },
  listContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    flexGrow: 1,
  },
  card: {
    backgroundColor: '#FFFCF8',
    padding: 16,
    marginBottom: 12,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 12,
  },
  cardHeaderLeft: {
    flex: 1,
  },
  locationBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 14,
    borderWidth: 1,
    marginLeft: 8,
  },
  locationBadgeSite: {
    backgroundColor: '#F7F0E7',
    borderColor: '#EDE1D3',
  },
  locationBadgeWorker: {
    backgroundColor: '#D98CA0',
    borderColor: '#D98CA0',
  },
  locationBadgeText: {
    fontFamily: 'IBMPlexMono_400Regular',
    fontSize: 10,
    color: '#8C7F72',
  },
  locationBadgeTextWorker: {
    color: '#C25B6E',
  },
  workerName: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 18,
    marginBottom: 2,
  },
  machineName: {
    fontFamily: 'Inter_400Regular',
    color: '#8C7F72',
    fontSize: 14,
  },
  cardDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: '#EDE1D3',
    paddingTop: 12,
  },
  cardDetailsHistory: {
    borderTopWidth: 1,
    borderTopColor: '#EDE1D3',
    paddingTop: 12,
  },
  detailText: {
    fontFamily: 'IBMPlexMono_400Regular',
    color: '#8C7F72',
    fontSize: 12,
  },
  timeBlock: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  timeLabel: {
    fontFamily: 'IBMPlexMono_400Regular',
    color: '#3A322B',
    fontSize: 12,
    width: 36,
  },
  historySubItem: {
    paddingVertical: 12,
  },
  historySubItemBorder: {
    borderTopWidth: 1,
    borderTopColor: '#EDE1D3',
  },
  machineNameHistory: {
    fontFamily: 'Inter_500Medium',
    color: '#3A322B',
    fontSize: 14,
    marginBottom: 8,
  },
  timeBlockContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingRight: 16,
  },
  returnButton: {
    backgroundColor: '#F7F0E7',
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
  },
  returnButtonText: {
    fontFamily: 'Inter_500Medium',
    color: '#3A322B',
    fontSize: 12,
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
    marginBottom: 8,
    textAlign: 'center',
  },
  retryButton: {
    backgroundColor: '#EFE6D8',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 14,
  },
  retryButtonText: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 12,
  },
  errorBanner: {
    marginHorizontal: 24,
    marginBottom: 16,
    backgroundColor: '#B94A4A',
    padding: 12,
    borderRadius: 14,
  },
  errorBannerText: {
    fontFamily: 'Inter_500Medium',
    color: '#FFFCF8',
    fontSize: 14,
  },
});
