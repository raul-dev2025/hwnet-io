// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * main.c - Funcion principal
 *
 * Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
 */

#include <linux/module.h>      // Requerido para la infraestructura de módulos
#include <linux/init.h>        // Para los atributos de inicialización/limpieza init/exit).
#include <linux/netdevice.h>   // Estructucturas net y funciones de estado de cola
#include <linux/etherdevice.h> // Utilidades Ethernet como eth_hw_addr_random
#include <linux/skbuff.h>      // Definición sk_buff y funciones de gestión como dev_kfree_skb

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Raul Vilchez");
MODULE_DESCRIPTION("Simple net device");
MODULE_VERSION("0.0.1");

struct hwnet_priv
{
  struct net_device *dev;
};

static int hwnet_open(struct net_device *dev)
{
  netif_start_queue(dev);
  return 0;
}

static int hwnet_close(struct net_device *dev)
{
  netif_stop_queue(dev);
  return 0;
}

static netdev_tx_t hwnet_xmit(struct sk_buff *skb, struct net_device *dev)
{
  dev->stats.tx_packets++;
  dev->stats.tx_bytes += skb->len;

  dev_kfree_skb(skb);

  return NETDEV_TX_OK;
}

static const struct net_device_ops hwnet_netdev_ops = {
    .ndo_open = hwnet_open,
    .ndo_stop = hwnet_close,
    .ndo_start_xmit = hwnet_xmit,
};

static void hwnet_setup(struct net_device *dev)
{
  ether_setup(dev);
  dev->netdev_ops = &hwnet_netdev_ops;
  eth_hw_addr_random(dev);
}

static struct net_device *hwnet_dev;

static int __init hwnet_init_module(void)
{
  struct hwnet_priv *priv;
  int ret;

  hwnet_dev = alloc_etherdev(sizeof(struct hwnet_priv));
  if (!hwnet_dev)
    return -ENOMEM;

  hwnet_setup(hwnet_dev);

  priv = netdev_priv(hwnet_dev);
  priv->dev = hwnet_dev;

  ret = register_netdev(hwnet_dev);
  if (ret)
  {
    free_netdev(hwnet_dev);
    return ret;
  }

  return 0;
}

static void __exit hwnet_cleanup_module(void)
{
  unregister_netdev(hwnet_dev);
  free_netdev(hwnet_dev);
}

module_init(hwnet_init_module);
module_exit(hwnet_cleanup_module);