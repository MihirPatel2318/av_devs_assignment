# Architecture Notes

## State Management
**Riverpod** - Chosen for compile-time safety, better testability, provider composition, and clean separation of business logic from UI.

## Project Structure
```
lib/
├── models/              - Data models (Product, CartItem, Order)
├── services/            - External services
│   ├── api_service.dart           - REST API integration
│   ├── cart_storage_service.dart  - Cart persistence
│   ├── order_storage_service.dart - Order history persistence
│   ├── connectivity_service.dart  - Network monitoring
│   └── analytics_service.dart     - Usage tracking
├── providers/           - Riverpod state providers
│   ├── products_provider.dart     - Products with search/filters
│   ├── cart_provider.dart         - Cart management
│   └── order_provider.dart        - Order history
├── screens/             - UI screens
│   ├── product_list_screen.dart   - Products with search/filter
│   ├── product_detail_screen.dart - Product details
│   ├── cart_screen.dart           - Shopping cart
│   └── orders_screen.dart         - Order history
├── widgets/             - Reusable widgets
│   └── shimmer_widgets.dart       - Loading skeletons
├── utils/               - Utilities
│   ├── app_exception.dart         - Custom exceptions
│   └── error_handler.dart         - Error handling
└── main.dart            - App entry with bottom navigation
```

## Key Features Implemented

### 1. Search & Filtering
- Real-time product search with 500ms debounce
- Category-based filtering
- Search and filter maintain pagination
- Clear search functionality

### 2. Error Handling
- Custom exception types (NoInternet, Timeout, etc.)
- User-friendly error messages
- Retry functionality on errors
- Connectivity monitoring
- API failure tracking

### 3. Pull-to-Refresh
- RefreshIndicator on product list
- Refreshes current view (search/filter/all)
- Smooth user experience

### 4. Loading States
- Shimmer skeleton loaders for products
- Progressive image loading with placeholders
- Loading indicators for pagination
- Separate loading states for different operations

### 5. Category Filtering
- Dynamic category loading from API
- Modal bottom sheet for category selection
- Radio button selection with "All Products" option
- Category state persisted during pagination

### 6. Optimistic Updates
- Cart updates UI immediately
- Background persistence without blocking
- Instant feedback for better UX

### 7. Image Optimization
- Cached network images (bandwidth optimization)
- Loading placeholders with progress indicators
- Error fallback widgets
- Image carousel with page indicators on detail screen

### 8. Analytics & Monitoring
- Product view tracking
- API failure monitoring
- Cart abandonment tracking
- Order statistics (total orders, total spent)

### 9. Better Cart UX
- Swipe-to-delete with Slidable
- Undo delete with SnackBar action
- Quantity controls with +/- buttons
- Delete icon button as alternative
- Visual feedback for all actions
- "In Cart" indicator on product details

### 10. Order History
- Complete order tracking
- Order details with expandable cards
- Total orders and spending statistics
- Formatted dates and times
- Order status indicators
- Bottom navigation for easy access

## State Management Architecture

### ProductsNotifier
- Manages product list with pagination
- Handles search queries with state tracking
- Category filtering with reset logic
- Refresh functionality maintains current view
- Analytics integration for failures

### CartNotifier
- Optimistic state updates (sync UI)
- Background persistence (async storage)
- Add, remove, update quantity operations
- Cart clearing on checkout
- Total calculations

### OrdersNotifier
- Order history management
- Persistent storage
- Statistics calculations
- Async loading with proper states

## API Integration

### Enhanced API Service
- Timeout handling (30s)
- Proper exception types
- Search endpoint integration
- Category filtering endpoint
- Categories list endpoint
- Retry-friendly error handling

### API Optimization
- Products loaded in batches of 20
- Pagination at 90% scroll threshold
- Single endpoint call per operation
- Search/filter maintain pagination
- Cached images reduce bandwidth

## Data Persistence

### Local Storage Strategy
- SharedPreferences for cart (JSON)
- SharedPreferences for orders (JSON)
- SharedPreferences for analytics
- Automatic save on operations
- Load on app startup

## UI/UX Enhancements

### Navigation
- Bottom navigation (Products/Orders)
- Material Design 3 theming
- Cart badge with item count
- Proper back navigation
- Screen state preservation

### Interaction Patterns
- Swipe-to-delete in cart
- Pull-to-refresh on product list
- Search with debounce
- Filter with modal bottom sheet
- Undo delete with SnackBar

### Visual Feedback
- Shimmer loading skeletons
- Progress indicators
- Empty state messages
- Error state with retry
- Success/failure snackbars
- "In Cart" badges

## Performance Considerations

### Network Efficiency
- Image caching (CDN + local)
- Pagination prevents mass loading
- Debounced search (500ms)
- Timeout handling (30s)
- Connection monitoring

### State Optimization
- Optimistic UI updates
- Selective widget rebuilds
- Proper provider scoping
- Immutable state updates
- StateNotifier for complex state

### Memory Management
- Cached images auto-cleanup
- Pagination limits memory usage
- Proper dispose of controllers
- StreamController cleanup

## Error Handling Strategy

### Exception Hierarchy
```
AppException (base)
├── NoInternetException
├── TimeoutException
├── FetchDataException
├── BadRequestException
└── UnauthorisedException
```

### Error Recovery
- Automatic retry suggestions
- Clear error messages
- Graceful degradation
- Offline detection
- Connection monitoring

## Future Scalability

The architecture supports easy addition of:
- User authentication
- Product reviews
- Wishlist feature
- Payment integration
- Push notifications
- Advanced analytics
- Offline mode
- Social sharing

## Testing Ready

Structure enables:
- Unit tests for providers
- Widget tests for screens
- Integration tests for flows
- Mock services for testing
- Isolated business logic
