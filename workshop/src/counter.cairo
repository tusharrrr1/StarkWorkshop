#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
    fn increase_counter(ref self: TContractState, _value: u32);
}

#[starknet::contract]
pub mod Counter {
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait;
use core::starknet::event::EventEmitter;
    use starknet::{get_caller_address, ContractAddress};
    use kill_switch::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};
    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: ContractAddress,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    // this event will emit whenever the state variable counter increases
    #[derive(Drop, PartialEq, starknet::Event)]
    struct CounterIncreased {
       #[key]
       pub value: u32
    }

    // event enum 
    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    pub enum Event {
        CounterIncreased: CounterIncreased,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, counter: u32, kill_switch: ContractAddress, initial_owner: ContractAddress) {
        self.ownable.initializer(initial_owner);
        self.counter.write(counter);
        self.kill_switch.write(kill_switch);
    }

    #[abi(embed_v0)]
    impl counter_contract of super::ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            return self.counter.read();
        }

        fn increase_counter(ref self: ContractState, _value: u32) {
            self.ownable.assert_only_owner();
            let status: bool = IKillSwitchDispatcher {contract_address: self.kill_switch.read()}.is_active();
            assert!(status == true, "Kill Switch is active");
            self.counter.write(_value);
            self.emit(Event::CounterIncreased(CounterIncreased{value: _value}));
        }
    }
}