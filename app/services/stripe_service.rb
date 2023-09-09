require 'stripe'

class StripeService
	def initialize()
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']
	end

	def find_or_create_customer(customer)
		if customer.stripe_customer_id.present?
			stripe_customer = Stripe::Customer.retrieve(customer.stripe_customer_id)
		else
			stripe_customer = Stripe::Customer.create({name: customer.full_name, email: customer.email, phone: customer.contact_number})
			customer.update(stripe_customer_id: stripe_customer.id)
		end
		stripe_customer
	end

	#This function is not implemented , just returning a test token.
	def create_card_token(params)
		card_token = 'tok_amex'
	end

	def create_stripe_cutomer_card(params,stripe_customer)
		token = create_card_token(params)
		#Should pass token.id for source, but the above is just a test token
		Stripe::Customer.create_source(
			stripe_customer.id,
			{ source: token } 
		)
	end

	def create_stripe_charge(amount_to_be_paid, stripe_customer_id, card_id, workshop)
		Stripe::Charge.create({
			amount: amount_to_be_paid,
			currency: 'inr',
			source: card_id,
			customer: stripe_customer_id,
			description: "Amount $#{amount_to_be_paid} charged for #{workshop.name}."
		})
	end

end