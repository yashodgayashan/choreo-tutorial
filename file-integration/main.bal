import ballerina/io;
import ballerina/log;

public function main() returns error? {
    // Define file paths
    string inputFilePath = "./input.txt";
    string outputFilePath = "./output.txt";
    
    // Write content to input file
    string content = "Hello, Ballerina!";
    check io:fileWriteString(inputFilePath, content);
    log:printInfo("Content written to: " + inputFilePath);
    
    // Read content from input file
    string readContent = check io:fileReadString(inputFilePath);
    log:printInfo("Content read: " + readContent);
    
    // Process the content (simple transformation)
    string processedContent = readContent + "\nProcessed with Ballerina!";
    
    // Write processed content to output file
    check io:fileWriteString(outputFilePath, processedContent);
    log:printInfo("Processed content written to: " + outputFilePath);
    
    log:printInfo("File integration completed successfully!");
}
