export const formatDate = (isoString: string | null | undefined) => {
  if (!isoString) return 'Still assigned';
  const date = new Date(isoString);
  return date.toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });
};
