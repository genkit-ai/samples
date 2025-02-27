import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const productData = [
  {
    id: 1,
    name: 'Classic Blue T-Shirt',
    description: 'Comfortable cotton t-shirt in classic blue',
    stockLevel: 50,
    price: 19.99,
    sku: 'BLU-TSHIRT-M',
  },
  {
    id: 2,
    name: 'Running Shoes',
    description: 'Lightweight running shoes with cushioned sole',
    stockLevel: 25,
    price: 89.99,
    sku: 'RUN-SHOE-42',
  },
  {
    id: 3,
    name: 'Denim Jeans',
    description: 'Classic fit denim jeans in dark wash',
    stockLevel: 75,
    price: 49.99,
    sku: 'DEN-JEAN-32',
  },
  {
    id: 4,
    name: 'Leather Wallet',
    description: 'Genuine leather bifold wallet',
    stockLevel: 100,
    price: 29.99,
    sku: 'LEA-WALL-01',
  },
  {
    id: 5,
    name: 'Wireless Headphones',
    description: 'Noise-cancelling wireless headphones',
    stockLevel: 30,
    price: 149.99,
    sku: 'WIR-HEAD-BK',
  }
];

const customerData = [
  {
    id: 1,
    name: 'John Doe',
    email: 'john.doe@example.com',
  },
  {
    id: 2,
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
  },
  {
    id: 3,
    name: 'Bob Wilson',
    email: 'bob.wilson@example.com',
  }
];

const orderData = [
  {
    customerId: 1,
    status: 'DELIVERED',
    trackingNumber: 'TRACK123456',
    orderItems: [
      { productId: 1, quantity: 2 },
      { productId: 2, quantity: 1 }
    ],
  },
  {
    customerId: 2,
    status: 'PROCESSING',
    trackingNumber: 'TRACK789012',
    orderItems: [
      { productId: 3, quantity: 1 }
    ],
  },
  {
    customerId: 3,
    status: 'PENDING',
    trackingNumber: 'TRACK345678',
    orderItems: [
      { productId: 4, quantity: 1 },
      { productId: 5, quantity: 1 }
    ],
  }
];

async function cleanDatabase() {
  console.log('Cleaning existing database data...');
  await prisma.orderItem.deleteMany();
  await prisma.order.deleteMany();
  await prisma.escalation.deleteMany();
  await prisma.product.deleteMany();
  await prisma.customer.deleteMany();
}

async function seedProducts() {
  console.log('Seeding products...');
  const results = await Promise.allSettled(
    productData.map(async (product) => {
      return prisma.product.upsert({
        where: { id: product.id },
        update: product,
        create: product,
      });
    })
  );

  const failures = results.filter((result) => result.status === 'rejected');
  if (failures.length > 0) {
    console.error('Some products failed to seed:', failures);
  }

  const succeeded = results.filter((result) => result.status === 'fulfilled');
  console.log(`Successfully seeded ${succeeded.length} products`);
}

async function seedCustomers() {
  console.log('Seeding customers...');
  const results = await Promise.allSettled(
    customerData.map(async (customer) => {
      return prisma.customer.upsert({
        where: { id: customer.id },
        update: customer,
        create: customer,
      });
    })
  );

  const failures = results.filter((result) => result.status === 'rejected');
  if (failures.length > 0) {
    console.error('Some customers failed to seed:', failures);
  }

  const succeeded = results.filter((result) => result.status === 'fulfilled');
  console.log(`Successfully seeded ${succeeded.length} customers`);
}

async function seedOrders() {
  console.log('Seeding orders...');
  for (const order of orderData) {
    await prisma.order.create({
      data: {
        customerId: order.customerId,
        status: order.status,
        trackingNumber: order.trackingNumber,
        orderItems: {
          create: order.orderItems,
        },
      },
    });
  }
  console.log('Successfully seeded orders');
}

async function main() {
  try {
    await cleanDatabase();
    await seedProducts();
    await seedCustomers();
    await seedOrders();
    console.log('Database seeding completed successfully');
  } catch (error) {
    console.error('Error seeding database:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error('Failed to seed database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });