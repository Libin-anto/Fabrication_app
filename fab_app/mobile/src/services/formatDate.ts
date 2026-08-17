export const formatDate = (isoString: string | null | undefined) => {
  if (!isoString) return 'Still assigned';
  
  // If the backend sends a naive UTC datetime string (missing Z), append 'Z'
  const timeString = isoString.endsWith('Z') || isoString.includes('+') ? isoString : `${isoString}Z`;
  
  const date = new Date(timeString);
  return date.toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });
};
