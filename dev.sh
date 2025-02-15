# Step 1: Stop Redis or kill process on port 6379
if pgrep redis-server > /dev/null; then
    echo "Stopping Redis..."
    pkill redis-server
else
    echo "No Redis process found. Checking port 6379..."
    fuser -k 6379/tcp 2>/dev/null && echo "Killed process on port 6379"
fi

# Step 2: Kill process on port 5432 (PostgreSQL)
if lsof -i :5432 > /dev/null; then
    echo "Killing process on port 5432..."
    fuser -k 5432/tcp
else
    echo "No process found on port 5432."
fi

# Step 3: Execute docker-compose up
echo "Starting Docker Compose..."
docker-compose up
