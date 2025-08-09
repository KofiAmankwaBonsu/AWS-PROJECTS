// ===============================
// Constants and Global Variables
// ===============================
const API_ENDPOINT = '';
let api = null;
let addTruckModal = null;
let detailsModal = null;

// ===============================
// API Service Class
// ===============================
class TruckApiService {
    constructor(apiEndpoint) {
        this.apiEndpoint = apiEndpoint;
        console.log('API Service initialized with endpoint:', apiEndpoint);
    }

    async checkOptionsRequest() {
        try {
            console.log('Sending OPTIONS request to:', this.apiEndpoint); // Debug log

            const response = await fetch(this.apiEndpoint, {
                method: 'OPTIONS',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'Access-Control-Request-Method': 'GET',
                    'Access-Control-Request-Headers': 'content-type'
                },
                mode: 'cors'
            });

            console.log('OPTIONS Response status:', response.status); // Debug log
            console.log('OPTIONS Response headers:', Object.fromEntries(response.headers));

            return response.ok;
        } catch (error) {
            console.error('OPTIONS request failed:', error);
            throw error;
        }
    }

    async getTrucks() {
        try {
            console.log('Fetching trucks from:', this.apiEndpoint);
            const response = await fetch(this.apiEndpoint, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                mode: 'cors'
            });

            console.log('Response status:', response.status);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            console.log('Received truck data:', data);
            return Array.isArray(data) ? data : [];
        } catch (error) {
            console.error('Error fetching trucks:', error);
            throw error;
        }
    }

    async addTruck(truck) {
        try {
            const response = await fetch(this.apiEndpoint, {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                mode: 'cors',
                body: JSON.stringify(truck)
            });

            const data = await response.json();
            console.log('Add truck response:', data);

            if (!response.ok) {
                throw new Error(`Failed to add truck: ${response.status}`);
            }

            console.log('API Response:', data);
            return data;
        } catch (error) {
            console.error('Error adding truck:', error);
            throw error;
        }
    }
}
// ===============================
// Utility Functions
// ===============================
function getStatusClass(status) {
    switch (status.toLowerCase()) {
        case 'active':
            return 'status-active';
        case 'maintenance':
            return 'status-maintenance';
        case 'off-duty':
            return 'status-offduty';
        default:
            return ''; // default case if status doesn't match
    }
}

function getStatusIcon(status) {
    switch (status.toLowerCase()) {
        case 'active':
            return 'ri-checkbox-circle-line';
        case 'maintenance':
            return 'ri-tools-line';
        case 'off-duty':
            return 'ri-stop-circle-line';
        default:
            return 'ri-question-line'; // default icon if status doesn't match
    }
}

function getWeightStatus(weight) {
    // Assuming weight is in tons and max capacity is 40 tons
    const maxWeight = 40;
    const weightNum = parseFloat(weight);
    return weightNum >= maxWeight;
}

function getWeightClass(weight) {
    return getWeightStatus(weight) ? 'weight-alert blink' : 'weight-normal';
}

// ===============================
// UI Display Functions
// ===============================
async function displayTrucks() {
    console.log('Starting displayTrucks function');
    const truckContainer = document.getElementById('truckContainer');

    if (!truckContainer) {
        console.error('Truck container not found!');
        return;
    }

    try {
        truckContainer.innerHTML = '<p>Loading trucks...</p>';

        const trucks = await api.getTrucks();
        console.log('Trucks received:', trucks);

        if (!trucks || trucks.length === 0) {
            truckContainer.innerHTML = '<p>No trucks available.</p>';
            return;
        }

        truckContainer.innerHTML = trucks.map(truck => `
            <div class="truck-card">
                <div class="truck-header">
                    <i class="truck-icon ri-truck-line"></i>
                    <h3>Truck ${truck.id}</h3>
                </div>
                
                <div class="status-container">
                    <div class="truck-status ${getStatusClass(truck.status)}">
                        <i class="${getStatusIcon(truck.status)}"></i>
                        ${truck.status}
                    </div>
                    ${getWeightStatus(truck.weight) ? 
                        '<div class="weight-alert blink"><i class="ri-error-warning-line"></i>FULL</div>' : 
                        ''
                    }
                </div>
                
                <div class="truck-info">
                    <p>
                        <i class="ri-user-line"></i>
                        <span>${truck.driver}</span>
                    </p>
                    <p>
                        <i class="ri-route-line"></i>
                        <span>${truck.route}</span>
                    </p>
                    <p>
                        <i class="ri-map-pin-line"></i>
                        <span>${truck.currentLocation}</span>
                    </p>
                    <p>
                        <i class="ri-scales-3-line"></i>
                        <span>${truck.weight} tons</span>
                    </p>
                </div>
                
                <button class="details-btn" data-truck='${JSON.stringify(truck)}'>
                    <i class="ri-information-line"></i>
                    View Details
                </button>
            </div>
        `).join('');

    } catch (error) {
        console.error('Error in displayTrucks:', error);
        truckContainer.innerHTML = `
            <div class="error-message">
                <p>Error loading trucks: ${error.message}</p>
                <button onclick="displayTrucks()">Try Again</button>
            </div>
        `;
    }
}

function showDetails(truck) {
    if (!detailsModal) {
        console.error('Details modal not found');
        return;
    }

    const detailsContent = document.getElementById('truckDetails');
    if (!detailsContent) {
        console.error('Truck details content element not found');
        return;
    }

    detailsContent.innerHTML = `
        <div class="details-grid">
            <div class="detail-item">
                <i class="ri-truck-line"></i>
                <div>
                    <label>Truck ID</label>
                    <span>${truck.id}</span>
                </div>
            </div>
            <div class="detail-item">
                <label>Driver:</label>
                <span>${truck.driver}</span>
            </div>
            <div class="detail-item">
                <label>Route:</label>
                <span>${truck.route}</span>
            </div>
            <div class="detail-item">
                <label>Status:</label>
                <span class="${getStatusClass(truck.status)}">
                    <i class="${getStatusIcon(truck.status)}"></i>
                    ${truck.status}
                </span>
            </div>
            <div class="detail-item">
                <label>Location:</label>
                <span>${truck.currentLocation}</span>
            </div>
            <div class="detail-item">
                <label>Fuel Level:</label>
                <span>${truck.fuelLevel}%</span>
            </div>
            <div class="detail-item">
                <label>Next Maintenance:</label>
                <span>${truck.nextMaintenance}</span>
            </div>
            <div class="detail-item">
                <i class="ri-scales-3-line"></i>
                <div>
                    <label>Weight</label>
                    <span>
                      ${truck.weight} tons
                      ${getWeightStatus(truck.weight) ?
                        '<span class="weight-alert blink">FULL</span>' : ''}</span>
                </div>
            </div>
            <div class="detail-item">
                <i class="ri-time-line"></i>
                <div>
                    <label>Last Updated</label>
                    <span>${new Date(truck.lastUpdated).toLocaleString()}</span>
                </div>
            </div>
        </div>
    `;

    detailsModal.style.display = 'block';
}

// ===============================
// Event Handlers
// ===============================
function setupModalHandlers() {

    // Add truck button click handler
    const addTruckBtn = document.getElementById('addTruckBtn');
    if (addTruckBtn) {
        addTruckBtn.addEventListener('click', () => {
            const addTruckModal = document.getElementById('addTruckModal');
            if (addTruckModal) {
                addTruckModal.style.display = 'block';
            }
        });
    }

    // Close buttons handler
    const closeButtons = document.querySelectorAll('.close');
    closeButtons.forEach(button => {
        button.addEventListener('click', () => {
            if (addTruckModal) addTruckModal.style.display = 'none';
            if (detailsModal) detailsModal.style.display = 'none';
        });
    });

    // Cancel button handler
    const cancelBtn = document.querySelector('.cancel-btn');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', () => {
            if (addTruckModal) addTruckModal.style.display = 'none';
        });
    }

    // Details button handler using event delegation
    document.addEventListener('click', (e) => {
        const detailsBtn = e.target.closest('.details-btn');
        if (detailsBtn) {
            try {
                const truckData = JSON.parse(detailsBtn.getAttribute('data-truck'));
                showDetails(truckData);
            } catch (error) {
                console.error('Error handling details button click:', error);
            }
        }
    });


    // Add form submission handler
    const addTruckForm = document.getElementById('addTruckForm');
    const submitButton = document.querySelector('#addTruckForm button[type="submit"]');

    if (addTruckForm) {
        addTruckForm.addEventListener('submit', handleFormSubmit);
    }

}

// ===============================
// Form Handling
// ===============================
async function handleFormSubmit(e) {
    e.preventDefault();

    const submitButton = e.target.querySelector('button[type="submit"]');
    if (!submitButton) return;

    const newTruck = {
        id: document.getElementById('truckId').value,
        driver: document.getElementById('driver').value,
        route: document.getElementById('route').value,
        status: document.getElementById('status').value,
        weight: document.getElementById('weight').value,
        currentLocation: document.getElementById('currentLocation').value,
        fuelLevel: document.getElementById('fuelLevel').value,
        nextMaintenance: document.getElementById('nextMaintenance').value,
        lastUpdated: new Date().toISOString()
    };

    try {
        submitButton.disabled = true;
        submitButton.innerHTML = '<i class="ri-loader-4-line"></i> Adding...';

        const result = await api.addTruck(newTruck);
        console.log('Truck added successfully:', result);

        await displayTrucks(); // Refresh the display

        if (addTruckModal) {
            addTruckModal.style.display = 'none';
            e.target.reset(); // Reset the form
        }
    } catch (error) {
        console.error('Failed to add truck:', error);
        alert(`Failed to add truck: ${error.message}`);
    } finally {
        submitButton.disabled = false;
        submitButton.innerHTML = 'Add Truck';
    }
}

// ===============================
// Initialization
// ===============================
async function initializeApp() {
    try {
        console.log('Initializing application...');

        // Initialize API service
        api = new TruckApiService(API_ENDPOINT);

        // Initialize modal elements
        addTruckModal = document.getElementById('addTruckModal');
        detailsModal = document.getElementById('detailsModal');

        // Setup event handlers
        setupModalHandlers();

        // Load initial data
        await displayTrucks();

        console.log('Application initialized successfully');
    } catch (error) {
        console.error('Error initializing application:', error);
    }
}

// ===============================
// Start Application
// ===============================
document.addEventListener('DOMContentLoaded', initializeApp);
