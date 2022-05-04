use types;
use sort;

fn cmpint(a: const *void, b: const *void) int = {
	return *(a: const *int)-*(b: const *int);
};

fn price(books: []int) f32 = {
	let slots: [5]int = [0...];
	for (let i = 0z; i < len(books); i += 1) {
		slots[books[i]] += 1;
	};

	sort::sort(slots, size(int), &cmpint);

	let total = 0.0;

	total += 8.0 * 5.0 * 0.75 * slots[0]: f32;
	total += 8.0 * 4.0 * 0.8 * (slots[1] - slots[0]): f32;
	total += 8.0 * 3.0 * 0.9 * (slots[2] - slots[1]): f32;
	total += 8.0 * 2.0 * 0.95 * (slots[3] - slots[2]): f32;
	total += 8.0 * (slots[4] - slots[3]): f32;

	return total;
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
