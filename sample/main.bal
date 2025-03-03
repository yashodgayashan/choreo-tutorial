import ballerina/http;
import ballerina/log;

// Define data structures.
type Product record {|
    int id;
    string name;
    float price;
|};

type OrderRequest record {|
    int productId;
    int quantity;
|};

type Order record {|
    int orderId;
    int productId;
    int quantity;
    float totalPrice;
|};

// Sample data
map<Product> products = {
    "1": {id: 1, name: "Laptop", price: 1200.00},
    "2": {id: 2, name: "Smartphone", price: 800.00},
    "3": {id: 3, name: "Headphones", price: 150.00}
};

map<Order> orders = {};
int orderCount = 0;

@display {
    label: "Shopping Service"
}
service /shop on new http:Listener(8090) {

    // List available products.
    resource function get products() returns Product[] {
        log:printInfo("Fetching product list");
        return products.toArray();
    }

    // Add a new product.
    resource function post product(@http:Payload Product product) returns http:Created|http:Conflict|error? {
        log:printInfo("Adding a new product");

        if (products.hasKey(product.id.toString())) {
            log:printError("Product already exists with product ID:" + product.id.toString());
            http:Conflict errorResponse = {
                body:  "Product already exists"
            };
            return errorResponse;
        }

        products[product.id.toString()] = product;
        log:printInfo("Product added successfully. " + product.toString());
        http:Created response = {
            body:  "Product added successfully"
        };
        return response;   
    }

    // Place a new order.
    resource function post 'order(@http:Payload OrderRequest orderRequest) returns http:Accepted|http:NotFound|error? {
        log:printInfo("Received order request");

        if !products.hasKey(orderRequest.productId.toString()) {
            log:printError("Product not found with product ID: " + orderRequest.productId.toString());
            http:NotFound errorResponse = {
                body:  "Product not found with product ID: " + orderRequest.productId.toString()
            };
            return errorResponse;
        }
        Product product = products.get(orderRequest.productId.toString());
        Order newOrder = {orderId: orderCount, productId: orderRequest.productId, quantity: orderRequest.quantity, totalPrice: product.price * orderRequest.quantity};
        orders[orderCount.toString()] = newOrder;
        orderCount += 1;

        log:printInfo("Order placed successfully. " + newOrder.toString());
        http:Accepted response = {
            body:  newOrder.toJson()
        };
        return response;
    }

    // Get order details by ID.
    resource function get 'order/[int orderId]() returns http:Ok|http:NotFound|error? {
        log:printInfo("Fetching order details");

        if (!orders.hasKey(orderId.toString())) {
            log:printError("Order not found with order ID: " + orderId.toString());
            http:NotFound errorResponse = {
                body:  "Order not found with order ID: " + orderId.toString()
            };
            return errorResponse;
        }

        Order 'order =  <Order> orders[orderId.toString()];
        log:printInfo("Order details fetched successfully. " + 'order.toString());
        http:Ok response = {
            body:  'order.toJson()
        };
        return response;
    }
}
