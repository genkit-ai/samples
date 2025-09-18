import { get, set } from 'idb-keyval';

export async function getItem<T>(key: string): Promise<T | undefined> {
  return await get(key);
}

export async function setItem<T>(key: string, value: T): Promise<void> {
  return await set(key, value);
}
