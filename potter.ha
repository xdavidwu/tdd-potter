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
