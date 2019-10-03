from util import *

class RestrictedBoltzmannMachine():
    '''
    For more details : A Practical Guide to Training Restricted Boltzmann Machines https://www.cs.toronto.edu/~hinton/absps/guideTR.pdf
    '''
    def __init__(self, ndim_visible, ndim_hidden, is_bottom=False, image_size=[28,28], is_top=False, n_labels=10, batch_size=10):

        """
        Args:
          ndim_visible: Number of units in visible layer.
          ndim_hidden: Number of units in hidden layer.
          is_bottom: True only if this rbm is at the bottom of the stack in a deep belief net. Used to interpret visible layer as image data with dimensions "image_size".
          image_size: Image dimension for visible layer.
          is_top: True only if this rbm is at the top of stack in deep beleif net. Used to interpret visible layer as concatenated with "n_label" unit of label data at the end.
          n_label: Number of label categories.
          batch_size: Size of mini-batch.
        """

        self.ndim_visible = ndim_visible

        self.ndim_hidden = ndim_hidden

        self.is_bottom = is_bottom

        if is_bottom : self.image_size = image_size

        self.is_top = is_top

        if is_top : self.n_labels = 10

        self.batch_size = batch_size

        self.delta_bias_v = 0

        self.delta_weight_vh = 0

        self.delta_bias_h = 0

        self.bias_v = np.random.normal(loc=0.0, scale=0.01, size=(self.ndim_visible))

        self.weight_vh = np.random.normal(loc=0.0, scale=0.01, size=(self.ndim_visible,self.ndim_hidden))

        self.bias_h = np.random.normal(loc=0.0, scale=0.01, size=(self.ndim_hidden))

        self.delta_weight_v_to_h = 0

        self.delta_weight_h_to_v = 0

        self.weight_v_to_h = None

        self.weight_h_to_v = None

        self.learning_rate = 0.01

        self.momentum = 0.7

        # velocities of momentum method
        self.w_v = np.zeros((self.ndim_visible,self.ndim_hidden))
        self.h_v = np.zeros((self.ndim_hidden))
        self.v_v = np.zeros((self.ndim_visible))


        #weight decay (L2)
        self.w_decay = 0.0001

        self.print_period = 5000

        self.rf = { # receptive-fields. Only applicable when visible layer is input data
            "period" : 5000, # iteration period to visualize
            "grid" : [5,5], # size of the grid
            "ids" : np.random.randint(0,self.ndim_hidden,25) # pick some random hidden units
            }

        return


    def cd1(self,visible_trainset, n_iterations=10000):

        """Contrastive Divergence with k=1 full alternating Gibbs sampling

        Args:
          visible_trainset: training data for this rbm, shape is (size of training set, size of visible layer)
          n_iterations: number of iterations of learning (each iteration learns a mini-batch)
        """

        print ("learning CD1")

        n_samples = visible_trainset.shape[0]

        #epoch??
        for it in range(n_iterations):

            if it % 250 == 0:
                print(it)

            #SEE THIS: https://en.wikipedia.org/wiki/Restricted_Boltzmann_machine#Training_algorithm
            #IT EXPLAINS CD1

            # positive phase
            v_0 = visible_trainset[self.batch_size*(it):self.batch_size*(it+1)]
            h_0 = self.get_h_given_v(v_0)[1]

            # negative phase
            v_k = self.get_v_given_h(h_0)[1]
            h_k = self.get_h_given_v(v_k)[1]

            # updating parameters
            self.update_params(v_0,h_0,v_k,h_k)

            # visualize once in a while when visible layer is input images

            if it % (self.rf["period"] -1) == 0 and self.is_bottom:

                viz_rf(weights=self.weight_vh[:,self.rf["ids"]].reshape((self.image_size[0],self.image_size[1],-1)), it=it, grid=self.rf["grid"], total_it=n_iterations,units=self.ndim_hidden)

            # print progress

            #?????????????????????????
            #it was (visible_trainset - visible_trainset)
            if it % (self.print_period -1) == 0 :

                print ("Iterations=%5d, units=%3d, iteration=%5d recon_loss=%4.4f"%(n_iterations,self.ndim_hidden,it+1, np.linalg.norm(visible_trainset - self.get_v_given_h(self.get_h_given_v(visible_trainset)[1])[1])))

        return


    def update_params(self,v_0,h_0,v_k,h_k):

        """Update the weight and bias parameters.

        You could also add weight decay and momentum for weight updates.

        Args:
           v_0: activities or probabilities of visible layer (data to the rbm)
           h_0: activities or probabilities of hidden layer
           v_k: activities or probabilities of visible layer
           h_k: activities or probabilities of hidden layer
           all args have shape (size of mini-batch, size of respective layer)
        """
        self.delta_bias_v = 0
        self.delta_weight_vh = 0
        self.delta_bias_h = 0

        for i in range(v_0.shape[0]):
            self.delta_bias_v += (v_0[i] - v_k[i])
            self.delta_weight_vh += (np.outer(v_0[i],h_0[i])-np.outer(v_k[i],h_k[i]))
            self.delta_bias_h += (h_0[i] - h_k[i])

        self.v_v = self.momentum*self.v_v + self.learning_rate*self.delta_bias_v
        self.w_v = self.momentum*self.w_v + self.learning_rate*self.delta_weight_vh
        self.h_v = self.momentum*self.h_v + self.learning_rate*self.delta_bias_h

        self.bias_v += self.v_v

        self.weight_vh += self.w_v + self.w_decay * np.square(self.weight_vh)/2 #sum?????

        self.bias_h += self.h_v

        return

    def get_h_given_v(self,visible_minibatch):

        """Compute probabilities p(h|v) and activations h ~ p(h|v)

        Uses undirected weight "weight_vh" and bias "bias_h"

        Args:
           visible_minibatch: shape is (size of mini-batch, size of visible layer)
        Returns:
           tuple ( p(h|v) , h)
           both are shaped (size of mini-batch, size of hidden layer)
        """

        ph = sigmoid(self.bias_h + np.dot(visible_minibatch,self.weight_vh))

        h = np.where(ph>0.5, 1, 0)

        return ph, h


    def get_v_given_h(self,hidden_minibatch):

        """Compute probabilities p(v|h) and activations v ~ p(v|h)

        Uses undirected weight "weight_vh" and bias "bias_v"

        Args:
           hidden_minibatch: shape is (size of mini-batch, size of hidden layer)
        Returns:
           tuple ( p(v|h) , v)
           both are shaped (size of mini-batch, size of visible layer)
        """

        if self.is_top:

            """
            Here visible layer has both data and labels. Compute total input for each unit (identical for both cases), \
            and split into two parts, something like support[:, :-self.n_labels] and support[:, -self.n_labels:]. \
            Then, for both parts, use the appropriate activation function to get probabilities and a sampling method \
            to get activities. The probabilities as well as activities can then be concatenated back into a normal visible layer.
            """

            pass

        else:
            pv = sigmoid(self.bias_v + np.dot(hidden_minibatch,np.transpose(self.weight_vh)))
            v = np.where(pv>0.5, 1, 0)

        return pv, v


    """ rbm as a belief layer : the functions below do not have to be changed until running a deep belief net """


    def untwine_weights(self):

        self.weight_v_to_h = np.copy( self.weight_vh )
        self.weight_h_to_v = np.copy( np.transpose(self.weight_vh) )
        self.weight_vh = None

    def get_h_given_v_dir(self,visible_minibatch):

        """Compute probabilities p(h|v) and activations h ~ p(h|v)

        Uses directed weight "weight_v_to_h" and bias "bias_h"

        Args:
           visible_minibatch: shape is (size of mini-batch, size of visible layer)
        Returns:
           tuple ( p(h|v) , h)
           both are shaped (size of mini-batch, size of hidden layer)
        """

        assert self.weight_v_to_h is not None

        n_samples = visible_minibatch.shape[0]

        return np.zeros((n_samples,self.ndim_hidden)), np.zeros((n_samples,self.ndim_hidden))


    def get_v_given_h_dir(self,hidden_minibatch):


        """Compute probabilities p(v|h) and activations v ~ p(v|h)

        Uses directed weight "weight_h_to_v" and bias "bias_v"

        Args:
           hidden_minibatch: shape is (size of mini-batch, size of hidden layer)
        Returns:
           tuple ( p(v|h) , v)
           both are shaped (size of mini-batch, size of visible layer)
        """

        assert self.weight_h_to_v is not None

        n_samples = hidden_minibatch.shape[0]

        if self.is_top:

            """
            Here visible layer has both data and labels. Compute total input for each unit (identical for both cases), \
            and split into two parts, something like support[:, :-self.n_labels] and support[:, -self.n_labels:]. \
            Then, for both parts, use the appropriate activation function to get probabilities and a sampling method \
            to get activities. The probabilities as well as activities can then be concatenated back into a normal visible layer.
            """

            pass

        else:

            pass

        return np.zeros((n_samples,self.ndim_visible)), np.zeros((n_samples,self.ndim_visible))

    def update_generate_params(self,inps,trgs,preds):

        """Update generative weight "weight_h_to_v" and bias "bias_v"

        Args:
           inps: activities or probabilities of input unit
           trgs: activities or probabilities of output unit (target)
           preds: activities or probabilities of output unit (prediction)
           all args have shape (size of mini-batch, size of respective layer)
        """

        self.delta_weight_h_to_v += 0
        self.delta_bias_v += 0

        self.weight_h_to_v += self.delta_weight_h_to_v
        self.bias_v += self.delta_bias_v

        return

    def update_recognize_params(self,inps,trgs,preds):

        """Update recognition weight "weight_v_to_h" and bias "bias_h"

        Args:
           inps: activities or probabilities of input unit
           trgs: activities or probabilities of output unit (target)
           preds: activities or probabilities of output unit (prediction)
           all args have shape (size of mini-batch, size of respective layer)
        """

        self.delta_weight_v_to_h += 0
        self.delta_bias_h += 0

        self.weight_v_to_h += self.delta_weight_v_to_h
        self.bias_h += self.delta_bias_h

        return