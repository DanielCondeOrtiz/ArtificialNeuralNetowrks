from util import *
from rbm import RestrictedBoltzmannMachine
from dbn import DeepBeliefNet
import threading

def train_net_epochs(epochs):
    print("Starting network with " + str(epochs) + " epochs, " + str(epochs*1000) + " iterations")
    rbm = RestrictedBoltzmannMachine(ndim_visible=image_size[0]*image_size[1],
                                     ndim_hidden=500,
                                     is_bottom=True,
                                     image_size=image_size,
                                     is_top=False,
                                     n_labels=10,
                                     batch_size=20
    )

    rbm.cd1(visible_trainset=train_imgs, n_iterations=epochs * 1000)

def call_epochs():
    threads = []
    for i in range(6):
        t = threading.Thread(target=train_net_epochs, args=(10+i*2,))
        threads.append(t)
        t.start()

    for th in threads:
        th.join()


def train_net_units(units,results):
    print("Starting network with " + str((units+2)*100) + " units")
    rbm = RestrictedBoltzmannMachine(ndim_visible=image_size[0]*image_size[1],
                                     ndim_hidden=(units+2)*100,
                                     is_bottom=True,
                                     image_size=image_size,
                                     is_top=False,
                                     n_labels=10,
                                     batch_size=20
    )

    res = rbm.cd1(visible_trainset=train_imgs, max_epochs=1, n_iterations=3000, bool_print=True)
    
    results[units,:] = res


def call_units():
    threads = []
    results = np.zeros((4,20))
    for i in range(4):
        t = threading.Thread(target=train_net_units, args=(i,results))
        threads.append(t)
        t.start()

    for th in threads:
        th.join()

    units = [200,300,400,500]
    fig, ax = plt.subplots()
    ax.plot(units, results)

    ax.set(xlabel='Hidden units', ylabel='Reconstruction loss',
           title='Average reconstruction loss')

    fig.savefig("hidden_loss.png")
    plt.show()


if __name__ == "__main__":

    image_size = [28,28]
    train_imgs,train_lbls,test_imgs,test_lbls = read_mnist(dim=image_size, n_train=60000, n_test=10000)

    ''' restricted boltzmann machine '''

    print ("\nStarting a Restricted Boltzmann Machine..")


    #basic

#    rbm = RestrictedBoltzmannMachine(ndim_visible=image_size[0]*image_size[1],
#                                     ndim_hidden=500,
#                                     is_bottom=True,
#                                     image_size=image_size,
#                                     is_top=False,
#                                     n_labels=10,
#                                     batch_size=20
#    )

    #recon_loss_ep = rbm.cd1(visible_trainset=train_imgs, n_iterations=3000, max_epochs=20, bool_print=True)

    #first point
    #threads so it doesn't take forever
    #call_epochs()

    #second point
    call_units()

    ''' deep- belief net '''

    print ("\nStarting a Deep Belief Net..")

    dbn = DeepBeliefNet(sizes={"vis":image_size[0]*image_size[1], "hid":500, "pen":500, "top":2000, "lbl":10},
                        image_size=image_size,
                        n_labels=10,
                        batch_size=10
    )

    ''' greedy layer-wise training '''

    dbn.train_greedylayerwise(vis_trainset=train_imgs, lbl_trainset=train_lbls, n_iterations=2000)

    dbn.recognize(train_imgs, train_lbls)

    dbn.recognize(test_imgs, test_lbls)

    for digit in range(10):
        digit_1hot = np.zeros(shape=(1,10))
        digit_1hot[0,digit] = 1
        dbn.generate(digit_1hot, name="rbms")
    #
    # ''' fine-tune wake-sleep training '''
    #
    # dbn.train_wakesleep_finetune(vis_trainset=train_imgs, lbl_trainset=train_lbls, n_iterations=2000)
    #
    # dbn.recognize(train_imgs, train_lbls)
    #
    # dbn.recognize(test_imgs, test_lbls)
    #
    # for digit in range(10):
    #     digit_1hot = np.zeros(shape=(1,10))
    #     digit_1hot[0,digit] = 1
    #     dbn.generate(digit_1hot, name="dbn")
