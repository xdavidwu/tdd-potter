fn price(books: []int) f32 = {
	return len(books): f32 * 8.0;
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
