use hash;
use hash::fnv;
use math;
use sort;

fn cmpint(a: const *void, b: const *void) int = {
	return *(a: const *int)-*(b: const *int);
};

def HASHMAP_BUCKETS: size = 256;

type res = struct {
	slots: [5]int,
	val: f32,
};

let hashmap: [HASHMAP_BUCKETS][]res = [[]...];

fn hashmap_insert(slots: [5]int, val: f32) void = {
	let hash = fnv::fnv64a();
	let buf: [_]u8 = [slots[0]: u8, slots[1]: u8, slots[2]: u8, slots[3]: u8, slots[4]: u8];
	hash::write(&hash, buf[..]);
	let v = res {
		slots = slots,
		val = val,
	};
	let bucket = &hashmap[fnv::sum64(&hash): size % HASHMAP_BUCKETS];
	append(bucket, v);
};

type notfound = !void;

fn hashmap_lookup(slots: [5]int) (f32 | notfound) = {
	let hash = fnv::fnv64a();
	let buf: [_]u8 = [slots[0]: u8, slots[1]: u8, slots[2]: u8, slots[3]: u8, slots[4]: u8];
	hash::write(&hash, buf[..]);
	let bucket = &hashmap[fnv::sum64(&hash): size % HASHMAP_BUCKETS];
	for (let i = 0z; i < len(bucket); i += 1) {
		if (bucket[i].slots[0] == slots[0] &&
				bucket[i].slots[1] == slots[1] &&
				bucket[i].slots[2] == slots[2] &&
				bucket[i].slots[3] == slots[3] &&
				bucket[i].slots[4] == slots[4]) {
			return bucket[i].val;
		};
	};
	return notfound;
};

fn price_slots(slots: [5]int) f32 = {
	sort::sort(slots, size(int), &cmpint);
	let min: f32 = math::INF;

	match (hashmap_lookup(slots)) {
	case let v: f32 =>
		return v;
	case notfound =>
		yield;
	};

	if (slots[0] != 0) {
		let nslots = slots;
		for (let i = 0; i < 5; i += 1) {
			nslots[i] -= 1;
		};
		let p = 8.0 * 5.0 * 0.75 + price_slots(nslots);
		min = if (p < min) p else min;
	};

	if (slots[1] != 0) {
		if (slots[0] != 0) {
			for (let j = 0; j < 5; j += 1) {
				let nslots = slots;
				for (let i = 0; i < 5; i += 1) {
					if (i == j) continue;
					nslots[i] -= 1;
				};
				let p = 8.0 * 4.0 * 0.8 + price_slots(nslots);
				min = if (p < min) p else min;
			};
		} else {
			let nslots = slots;
			for (let i = 1; i < 5; i += 1) {
				nslots[i] -= 1;
			};
			let p = 8.0 * 4.0 * 0.8 + price_slots(nslots);
			min = if (p < min) p else min;
		};
	};

	if (slots[2] != 0) {
		if (slots[0] != 0) {
			for (let j = 0; j < 5; j += 1) {
				for (let k = j + 1; k < 5; k += 1) {
					let nslots = slots;
					for (let i = 0; i < 5; i += 1) {
						if (i == j || i == k) continue;
						nslots[i] -= 1;
					};
					let p = 8.0 * 3.0 * 0.9 + price_slots(nslots);
					min = if (p < min) p else min;
				};
			};
		} else if (slots[1] != 0) {
			for (let j = 1; j < 5; j += 1) {
				let nslots = slots;
				for (let i = 1; i < 5; i += 1) {
					if (i == j) continue;
					nslots[i] -= 1;
				};
				let p = 8.0 * 3.0 * 0.9 + price_slots(nslots);
				min = if (p < min) p else min;
			};
		} else {
			let nslots = slots;
			for (let i = 2; i < 5; i += 1) {
				nslots[i] -= 1;
			};
			let p = 8.0 * 3.0 * 0.9 + price_slots(nslots);
			min = if (p < min) p else min;
		};
	};

	if (slots[3] != 0) {
		for (let i = 0; i < 5; i += 1) {
			if (slots[i] == 0) continue;
			for (let j = i + 1; j < 5; j += 1) {
				if (slots[j] == 0) continue;
				let nslots = slots;
				nslots[i] -= 1;
				nslots[j] -= 1;
				let p = 8.0 * 2.0 * 0.95 + price_slots(nslots);
				min = if (p < min) p else min;
			};
		};
	};

	if (slots[4] != 0) {
		for (let i = 0; i < 5; i += 1) {
			if (slots[i] == 0) continue;
			let nslots = slots;
			nslots[i] -= 1;
			let p = 8.0 + price_slots(nslots);
			min = if (p < min) p else min;
		};
	} else {
		// nothing left
		return 0.0;
	};
	hashmap_insert(slots, min);
	return min;
};

fn price(books: []int) f32 = {
	let slots: [5]int = [0...];
	for (let i = 0z; i < len(books); i += 1) {
		slots[books[i]] += 1;
	};

	return price_slots(slots);
};

@test fn basics() void = {
	assert(price([]) == 0.0);
	assert(price([1]) == 8.0);
	assert(price([2]) == 8.0);
	assert(price([3]) == 8.0);
	assert(price([4]) == 8.0);
	assert(price([1, 1, 1]) == 8.0 * 3.0);
};

@test fn simple_discounts() void = {
	assert(price([0, 1]) == 8.0 * 2.0 * 0.95);
	assert(price([0, 2, 4]) == 8.0 * 3.0 * 0.9);
	assert(price([0, 1, 2, 4]) == 8.0 * 4.0 * 0.8);
	assert(price([0, 1, 2, 3, 4]) == 8.0 * 5.0 * 0.75);
};

@test fn several_discounts() void = {
	assert(price([0, 0, 1]) == 8.0 + 8.0 * 2.0 * 0.95);
	assert(price([0, 0, 1, 1]) == 2.0 * 8.0 * 2.0 * 0.95);
	assert(price([0, 0, 1, 2, 2, 3]) == 8.0 * 4.0 * 0.8 + 8.0 * 2.0 * 0.95);
	assert(price([0, 1, 1, 2, 3, 4]) == 8.0 + 8.0 * 5.0 * 0.75);
};

@test fn edge_cases() void = {
	assert(price([0, 0, 1, 1, 2, 2, 3, 4]) == 2.0 * 8.0 * 4.0 * 0.8);
	assert(price([0, 0, 0, 0, 0,
		1, 1, 1, 1, 1,
		2, 2, 2, 2,
		3, 3, 3, 3, 3,
		4, 4, 4, 4]) == 3.0 * 8.0 * 5.0 * 0.75 + 2.0 * 8.0 * 4.0 * 0.8);
};
