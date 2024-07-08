import {Ok, Error} from "./gleam.mjs"

const Nil = undefined;
const cache = new Map();

export const get = (key) => {
    let value = cache.get(key);
    return value ? new Ok(value) : new Error(Nil);
};

export const put = (key, value) => {
    cache.set(key, value);
};