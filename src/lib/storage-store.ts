type Listener = () => void;

export function createStorageStore<T>(key: string, fallback: T) {
  let memory = fallback;
  const listeners = new Set<Listener>();

  const read = (): T => {
    if (typeof window === "undefined") return fallback;
    try {
      const raw = window.localStorage.getItem(key);
      return raw ? (JSON.parse(raw) as T) : fallback;
    } catch {
      return fallback;
    }
  };

  if (typeof window !== "undefined") {
    memory = read();
  }

  const emit = () => listeners.forEach((listener) => listener());

  return {
    subscribe(listener: Listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
    getSnapshot() {
      return memory;
    },
    getServerSnapshot() {
      return fallback;
    },
    set(next: T) {
      memory = next;
      if (typeof window !== "undefined") {
        window.localStorage.setItem(key, JSON.stringify(next));
      }
      emit();
    },
  };
}
